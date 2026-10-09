const express = require('express');
const db = require('../config/db');
const { getNextTransactionNumber } = require('../utils/transaction_number');
const { requireSalesWorkflowUser } = require('../middleware/workflow_auth');

const router = express.Router();
const CHALLAN_STATUSES = ['Draft', 'Shipped', 'Delivered', 'Void'];
const num = (value) => Number.isFinite(Number(value)) ? Number(value) : 0;

function mapItem(row) {
  return { id: Number(row.id), sourceType: row.source_type,
    itemId: row.item_id == null ? null : String(row.item_id), partId: row.part_id == null ? null : String(row.part_id),
    itemName: row.item_name || '', description: row.description || '',
    quantity: num(row.qty), rate: num(row.rate), amount: num(row.amount) };
}

function mapChallan(row, items = []) {
  return { id: String(row.id), challanNumber: row.challan_number,
    invoiceId: row.invoice_id == null ? null : String(row.invoice_id), invoiceNumber: row.invoice_number || null,
    salesOrderId: row.sales_order_id == null ? null : String(row.sales_order_id), salesOrderNumber: row.sales_order_number || null,
    estimateId: row.estimate_id == null ? null : String(row.estimate_id), estimateNumber: row.estimate_number || null,
    customerId: String(row.customer_id), customerName: row.customer_name,
    challanDate: row.challan_date, deliveryDate: row.delivery_date || null,
    transportationDetails: row.transportation_details || '', notes: row.notes || '', items, total: num(row.total), status: row.status };
}

async function loadChallan(queryable, id) {
  const [rows] = await queryable.query(`
    SELECT id,challan_number,invoice_id,invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,
      customer_id,customer_name,DATE_FORMAT(challan_date,'%Y-%m-%d') AS challan_date,
      DATE_FORMAT(delivery_date,'%Y-%m-%d') AS delivery_date,transportation_details,notes,total,status
    FROM delivery_challans WHERE id=? LIMIT 1
  `, [id]);
  if (!rows.length) return null;
  const [items] = await queryable.query(`
    SELECT id,source_type,item_id,part_id,item_name,description,qty,rate,amount
    FROM delivery_challan_items WHERE delivery_challan_id=? ORDER BY id ASC
  `, [id]);
  return mapChallan(rows[0], items.map(mapItem));
}

router.get('/next-number', async (req,res) => {
  try { const value=await getNextTransactionNumber({module:'Delivery Challan',table:'delivery_challans',numberColumn:'challan_number'}); return res.json({success:true,data:{challanNumber:value.transactionNumber}}); }
  catch(error){ return res.status(error.statusCode||500).json({success:false,message:error.message}); }
});

router.get('/', async (req,res) => {
  try {
    const {customer,dateFrom,dateTo,status}=req.query;
    let sql="SELECT id FROM delivery_challans WHERE 1=1"; const values=[];
    if(customer){sql+=" AND customer_name LIKE ?";values.push(`%${customer}%`)}
    if(dateFrom){sql+=" AND challan_date>=?";values.push(dateFrom)}
    if(dateTo){sql+=" AND challan_date<=?";values.push(dateTo)}
    if(status&&CHALLAN_STATUSES.includes(status)){sql+=" AND status=?";values.push(status)}
    sql+=" ORDER BY challan_date DESC,id DESC";
    const [rows]=await db.query(sql,values); const data=[];
    for(const row of rows)data.push(await loadChallan(db,row.id));
    return res.json({success:true,data});
  }catch(error){console.error('Get delivery challans error:',error);return res.status(500).json({success:false,message:'Failed to fetch Delivery Challans.'})}
});

router.post('/from-invoice/:invoiceId',requireSalesWorkflowUser,async(req,res)=>{
  const invoiceId=Number(req.params.invoiceId);
  if(!Number.isInteger(invoiceId)||invoiceId<=0)return res.status(400).json({success:false,message:'Invalid Invoice ID.'});
  const connection=await db.getConnection();
  try{
    await connection.beginTransaction();
    const [invoices]=await connection.query(`
      SELECT id,invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,customer_id,customer_name,total,notes,approval_status,document_status
      FROM invoices WHERE id=? FOR UPDATE
    `,[invoiceId]);
    if(!invoices.length){await connection.rollback();return res.status(404).json({success:false,message:'Invoice not found.'})}
    const invoice=invoices[0];
    if(invoice.document_status==='Void'){await connection.rollback();return res.status(409).json({success:false,message:'A void Invoice cannot be converted to a Delivery Challan.'})}
    if(invoice.approval_status!=='Approved'){await connection.rollback();return res.status(409).json({success:false,message:'Invoice must be approved before creating a Delivery Challan.'})}
    const [existing]=await connection.query(`
      SELECT id FROM delivery_challans
      WHERE invoice_id=? OR (? IS NOT NULL AND sales_order_id=?) LIMIT 1
    `,[invoiceId,invoice.sales_order_id,invoice.sales_order_id]);
    let challanId;const alreadyExists=existing.length>0;
    if(alreadyExists)challanId=existing[0].id;
    else{
      const number=await getNextTransactionNumber({module:'Delivery Challan',table:'delivery_challans',numberColumn:'challan_number',connection});
      const [created]=await connection.query(`
        INSERT INTO delivery_challans (challan_number,invoice_id,invoice_number,sales_order_id,sales_order_number,estimate_id,estimate_number,
          customer_id,customer_name,challan_date,notes,total,status)
        VALUES (?,?,?,?,?,?,?,?,?,CURRENT_DATE(),?,?,'Draft')
      `,[number.transactionNumber,invoice.id,invoice.invoice_number,invoice.sales_order_id,invoice.sales_order_number,invoice.estimate_id,invoice.estimate_number,invoice.customer_id,invoice.customer_name,invoice.notes,invoice.total]);
      challanId=created.insertId;
      const [sourceItems]=await connection.query('SELECT source_type,item_id,part_id,item_name,description,qty,rate,amount FROM invoice_items WHERE invoice_id=? ORDER BY id ASC',[invoiceId]);
      for(const line of sourceItems)await connection.query(`
        INSERT INTO delivery_challan_items (delivery_challan_id,source_type,item_id,part_id,item_name,description,qty,rate,amount) VALUES (?,?,?,?,?,?,?,?,?)
      `,[challanId,line.source_type,line.item_id,line.part_id,line.item_name,line.description,line.qty,line.rate,line.amount]);
    }
    await connection.commit();
    return res.status(alreadyExists?200:201).json({success:true,message:alreadyExists?'Existing Delivery Challan returned.':'Delivery Challan created from Invoice.',data:await loadChallan(db,challanId)});
  }catch(error){
    try{await connection.rollback()}catch(_){}
    if(error.code==='ER_DUP_ENTRY'){
      try{
        const [invoiceRows]=await db.query('SELECT sales_order_id FROM invoices WHERE id=? LIMIT 1',[invoiceId]);
        const sourceSalesOrderId=invoiceRows[0]?.sales_order_id ?? null;
        const [existing]=await db.query(`
          SELECT id FROM delivery_challans
          WHERE invoice_id=? OR (? IS NOT NULL AND sales_order_id=?) LIMIT 1
        `,[invoiceId,sourceSalesOrderId,sourceSalesOrderId]);
        if(existing.length)return res.status(200).json({success:true,message:'Existing Delivery Challan returned.',data:await loadChallan(db,existing[0].id)});
      }catch(_){}
    }
    console.error('Convert Invoice to Delivery Challan error:',error);
    return res.status(500).json({success:false,message:'Failed to create Delivery Challan from Invoice.'});
  }
  finally{connection.release()}
});

router.post('/from-sales-order/:salesOrderId',requireSalesWorkflowUser,async(req,res)=>{
  const salesOrderId=Number(req.params.salesOrderId);
  if(!Number.isInteger(salesOrderId)||salesOrderId<=0)return res.status(400).json({success:false,message:'Invalid Sales Order ID.'});
  const connection=await db.getConnection();
  try{
    await connection.beginTransaction();
    const [orders]=await connection.query(`
      SELECT id,so_number,estimate_id,estimate_number,customer_id,customer_name,order_date,total,notes,status,approval_status
      FROM sales_orders WHERE id=? FOR UPDATE
    `,[salesOrderId]);
    if(!orders.length){await connection.rollback();return res.status(404).json({success:false,message:'Sales Order not found.'})}
    const order=orders[0];
    if(order.approval_status!=='Approved'){await connection.rollback();return res.status(409).json({success:false,message:'Sales Order must be approved before conversion.'})}
    if(order.status==='Rejected'){await connection.rollback();return res.status(409).json({success:false,message:'A Rejected Sales Order cannot be converted.'})}
    const [existing]=await connection.query('SELECT id FROM delivery_challans WHERE sales_order_id=? LIMIT 1',[salesOrderId]);
    let challanId;const alreadyExists=existing.length>0;
    if(alreadyExists)challanId=existing[0].id;
    else{
      const [sourceItems]=await connection.query(`
        SELECT source_type,item_id,part_id,item_name,description,qty,rate,amount
        FROM sales_order_items WHERE sales_order_id=? ORDER BY id ASC
      `,[salesOrderId]);
      if(!sourceItems.length){await connection.rollback();return res.status(409).json({success:false,message:'Sales Order has no items to convert.'})}
      const number=await getNextTransactionNumber({module:'Delivery Challan',table:'delivery_challans',numberColumn:'challan_number',connection});
      const [created]=await connection.query(`
        INSERT INTO delivery_challans (challan_number,sales_order_id,sales_order_number,estimate_id,estimate_number,
          customer_id,customer_name,challan_date,notes,total,status)
        VALUES (?,?,?,?,?,?,?,CURRENT_DATE(),?,?,'Draft')
      `,[number.transactionNumber,order.id,order.so_number,order.estimate_id,order.estimate_number,
        order.customer_id,order.customer_name,order.notes,order.total]);
      challanId=created.insertId;
      for(const line of sourceItems)await connection.query(`
        INSERT INTO delivery_challan_items (delivery_challan_id,source_type,item_id,part_id,item_name,description,qty,rate,amount)
        VALUES (?,?,?,?,?,?,?,?,?)
      `,[challanId,line.source_type,line.item_id,line.part_id,line.item_name,line.description,line.qty,line.rate,line.amount]);
    }
    await connection.commit();
    return res.status(alreadyExists?200:201).json({success:true,message:alreadyExists?'Existing Delivery Challan returned.':'Delivery Challan created from Sales Order.',data:await loadChallan(db,challanId)});
  }catch(error){
    try{await connection.rollback()}catch(_){}
    if(error.code==='ER_DUP_ENTRY'){
      try{
        const [existing]=await db.query('SELECT id FROM delivery_challans WHERE sales_order_id=? LIMIT 1',[salesOrderId]);
        if(existing.length)return res.status(200).json({success:true,message:'Existing Delivery Challan returned.',data:await loadChallan(db,existing[0].id)});
      }catch(_){}
    }
    console.error('Convert Sales Order to Delivery Challan error:',error);
    return res.status(500).json({success:false,message:'Failed to create Delivery Challan from Sales Order.'});
  }finally{connection.release()}
});

router.get('/:id',async(req,res)=>{
  try{const challan=await loadChallan(db,Number(req.params.id));if(!challan)return res.status(404).json({success:false,message:'Delivery Challan not found.'});return res.json({success:true,data:challan})}
  catch(error){return res.status(500).json({success:false,message:'Failed to fetch Delivery Challan.'})}
});

router.post('/:id/clone',async(req,res)=>{
  const id=Number(req.params.id);
  if(!Number.isInteger(id)||id<=0)return res.status(400).json({success:false,message:'Invalid Delivery Challan ID.'});
  const connection=await db.getConnection();
  try{
    await connection.beginTransaction();
    const [rows]=await connection.query('SELECT * FROM delivery_challans WHERE id=? FOR UPDATE',[id]);
    if(!rows.length){await connection.rollback();return res.status(404).json({success:false,message:'Delivery Challan not found.'})}
    const source=rows[0];
    const number=await getNextTransactionNumber({module:'Delivery Challan',table:'delivery_challans',numberColumn:'challan_number',connection});
    const [created]=await connection.query(`
      INSERT INTO delivery_challans (
        challan_number,customer_id,customer_name,challan_date,transportation_details,notes,total,status
      ) VALUES (?,?,?,CURRENT_DATE(),?,?,?,'Draft')
    `,[number.transactionNumber,source.customer_id,source.customer_name,source.transportation_details,source.notes,source.total]);
    await connection.query(`
      INSERT INTO delivery_challan_items (
        delivery_challan_id,source_type,item_id,part_id,item_name,description,qty,rate,amount
      )
      SELECT ?,source_type,item_id,part_id,item_name,description,qty,rate,amount
      FROM delivery_challan_items WHERE delivery_challan_id=?
    `,[created.insertId,id]);
    await connection.commit();
    return res.status(201).json({success:true,message:'Delivery Challan cloned as Draft.',data:await loadChallan(db,created.insertId)});
  }catch(error){
    try{await connection.rollback()}catch(_){}
    console.error('Clone Delivery Challan error:',error);
    return res.status(500).json({success:false,message:'Failed to clone Delivery Challan.'});
  }finally{connection.release()}
});

router.post('/',(req,res)=>res.status(409).json({success:false,message:'Delivery Challans must be created from an approved Invoice using the workflow action.'}));

router.put('/:id',async(req,res)=>{
  const id=Number(req.params.id);const {deliveryDate,transportationDetails,status}=req.body;
  if(status!==undefined&&!CHALLAN_STATUSES.includes(status))return res.status(400).json({success:false,message:'Invalid Delivery Challan status.'});
  try{const [result]=await db.query('UPDATE delivery_challans SET delivery_date=COALESCE(?,delivery_date),transportation_details=COALESCE(?,transportation_details),status=COALESCE(?,status) WHERE id=?',[deliveryDate||null,transportationDetails??null,status??null,id]);if(!result.affectedRows)return res.status(404).json({success:false,message:'Delivery Challan not found.'});return res.json({success:true,data:await loadChallan(db,id)})}
  catch(error){return res.status(500).json({success:false,message:'Failed to update Delivery Challan.'})}
});

router.put('/:id/status',async(req,res)=>{
  if(!CHALLAN_STATUSES.includes(req.body.status))return res.status(400).json({success:false,message:'Invalid Delivery Challan status.'});
  try{const [result]=await db.query('UPDATE delivery_challans SET status=? WHERE id=?',[req.body.status,req.params.id]);if(!result.affectedRows)return res.status(404).json({success:false,message:'Delivery Challan not found.'});return res.json({success:true,message:'Delivery Challan status updated.'})}
  catch(error){return res.status(500).json({success:false,message:'Failed to update Delivery Challan status.'})}
});

router.delete('/:id',async(req,res)=>{
  try{const [result]=await db.query('DELETE FROM delivery_challans WHERE id=?',[req.params.id]);if(!result.affectedRows)return res.status(404).json({success:false,message:'Delivery Challan not found.'});return res.json({success:true,message:'Delivery Challan deleted.'})}
  catch(error){return res.status(500).json({success:false,message:'Failed to delete Delivery Challan.'})}
});

module.exports=router;
