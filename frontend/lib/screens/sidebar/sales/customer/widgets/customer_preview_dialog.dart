import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../customer_model.dart';
import '../customer_repository.dart';

class CustomerPreviewDialog extends StatefulWidget {
  const CustomerPreviewDialog({
    super.key,
    required this.customer,
    required this.repository,
    required this.onNewEstimate,
    required this.onNewSalesOrder,
  });

  final CustomerModel customer;
  final CustomerRepository repository;
  final Future<void> Function() onNewEstimate;
  final Future<void> Function() onNewSalesOrder;

  @override
  State<CustomerPreviewDialog> createState() => _CustomerPreviewDialogState();
}

class _CustomerPreviewDialogState extends State<CustomerPreviewDialog> {
  final TextEditingController _commentController = TextEditingController();
  List<CustomerComment> _comments = [];
  CustomerTransactions? _transactions;
  bool _isLoadingComments = true;
  bool _isSavingComment = false;
  bool _isLoadingTransactions = true;
  bool _isGeneratingStatement = false;
  String? _commentsError;
  String? _transactionsError;
  String? _statementError;
  late DateTime _statementStartDate;
  late DateTime _statementEndDate;

  static const _tabs = [
    'Business Overview',
    'Address',
    'Comments',
    'Transactions',
    'Statement',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _statementEndDate = today;
    _statementStartDate = DateTime(today.year - 1, today.month, today.day);
    _loadComments();
    _loadTransactions();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final customerId = widget.customer.id;
    if (customerId == null || customerId.isEmpty) {
      setState(() {
        _commentsError = 'Customer ID is missing.';
        _isLoadingComments = false;
      });
      return;
    }

    setState(() {
      _isLoadingComments = true;
      _commentsError = null;
    });

    try {
      final comments = await widget.repository.getCustomerComments(customerId);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _commentsError = error.toString();
        _isLoadingComments = false;
      });
    }
  }

  Future<void> _loadTransactions() async {
    final customerId = widget.customer.id;
    if (customerId == null || customerId.isEmpty) {
      setState(() {
        _transactionsError = 'Customer ID is missing.';
        _isLoadingTransactions = false;
      });
      return;
    }

    setState(() {
      _isLoadingTransactions = true;
      _transactionsError = null;
    });

    try {
      final transactions =
          await widget.repository.getCustomerTransactions(customerId);
      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _isLoadingTransactions = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _transactionsError = error.toString();
        _isLoadingTransactions = false;
      });
    }
  }

  Future<void> _saveComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty || _isSavingComment) return;

    final customerId = widget.customer.id;
    if (customerId == null || customerId.isEmpty) {
      setState(() => _commentsError = 'Customer ID is missing.');
      return;
    }

    setState(() {
      _isSavingComment = true;
      _commentsError = null;
    });

    try {
      final savedComment =
          await widget.repository.addCustomerComment(customerId, comment);
      if (!mounted) return;
      setState(() {
        _comments = [savedComment, ..._comments];
        _commentController.clear();
        _isSavingComment = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _commentsError = error.toString();
        _isSavingComment = false;
      });
    }
  }

  String _value(String value) => value.isEmpty ? '-' : value;

  String _address({
    required String street,
    required String city,
    required String state,
    required String zip,
    required String country,
  }) {
    return [
      street,
      [city, state, zip].where((part) => part.isNotEmpty).join(', '),
      country,
    ].where((part) => part.isNotEmpty).join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return DefaultTabController(
      length: _tabs.length,
      child: Dialog(
        insetPadding: const EdgeInsets.all(14),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: screenSize.width < 940 ? screenSize.width - 28 : 900,
          height: screenSize.height < 700
              ? screenSize.height - 28
              : screenSize.height * .9,
          child: Column(
            children: [
              _buildHeader(context),
              const Divider(height: 1),
              Material(
                color: Colors.white,
                child: TabBar(
                  isScrollable: true,
                  labelColor: const Color(0xFF3498DB),
                  unselectedLabelColor: const Color(0xFF454B52),
                  indicatorColor: const Color(0xFF3498DB),
                  tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOverview(),
                    _buildAddresses(),
                    _buildComments(),
                    _buildTransactions(),
                    _buildStatement(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 12, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _createEstimate,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Estimate'),
              ),
              OutlinedButton.icon(
                onPressed: _createSalesOrder,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Sales Order'),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          );

          final name = Text(
            widget.customer.vendorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF123456),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          );

          if (constraints.maxWidth < 650) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: name),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _createEstimate,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Estimate'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _createSalesOrder,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Sales Order'),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: name),
              actions,
            ],
          );
        },
      ),
    );
  }

  Future<void> _createEstimate() async {
    await widget.onNewEstimate();
    if (mounted) await _loadTransactions();
  }

  Future<void> _createSalesOrder() async {
    await widget.onNewSalesOrder();
    if (mounted) await _loadTransactions();
  }

  Widget _buildOverview() {
    final primaryContact = [
      widget.customer.salutation,
      widget.customer.firstName,
      widget.customer.lastName,
    ].where((part) => part.isNotEmpty).join(' ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailItem(
            label: 'Primary Contact',
            value: _value(primaryContact),
          ),
          _DetailItem(
            label: 'Company Name',
            value: _value(widget.customer.companyName),
          ),
          _DetailItem(
            label: 'Customer Email',
            value: _value(widget.customer.email),
          ),
          _DetailItem(
            label: 'Customer Phone',
            value: _value(widget.customer.phone),
          ),
          _DetailItem(
            label: 'Website',
            value: _value(widget.customer.website),
          ),
          _DetailItem(
            label: 'Customer Type',
            value: widget.customer.vendorType,
          ),
          _DetailItem(
            label: 'GST Applicable',
            value: widget.customer.gstApplicable,
          ),
          _DetailItem(
            label: 'Status',
            value: widget.customer.status,
          ),
        ],
      ),
    );
  }

  Widget _buildAddresses() {
    final billingAddress = _address(
      street: widget.customer.billingStreet,
      city: widget.customer.city,
      state: widget.customer.state,
      zip: widget.customer.billingZip,
      country: widget.customer.country,
    );
    final shippingAddress = widget.customer.shippingSameAsBilling
        ? 'Same as billing address'
        : _address(
            street: widget.customer.shippingStreet,
            city: widget.customer.shippingCity,
            state: widget.customer.shippingState,
            zip: widget.customer.shippingZip,
            country: widget.customer.shippingCountry,
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailItem(
            label: 'Billing Address',
            value: _value(billingAddress),
          ),
          _DetailItem(
            label: 'Shipping Address',
            value: _value(shippingAddress),
          ),
        ],
      ),
    );
  }

  Widget _buildComments() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Internal Comments',
            style: TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _commentController,
            minLines: 3,
            maxLines: 4,
            maxLength: 10000,
            enabled: !_isSavingComment,
            decoration: InputDecoration(
              hintText: 'Type your internal note here...',
              hintStyle: const TextStyle(color: Color(0xFF7A828A)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(7),
                borderSide: const BorderSide(color: Color(0xFFD9DEE5)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isSavingComment ? null : _saveComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: _isSavingComment
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Save Comment'),
          ),
          if (_commentsError != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _commentsError!,
                    style: const TextStyle(color: Color(0xFFAB2A2A)),
                  ),
                ),
                TextButton(
                  onPressed: _isLoadingComments ? null : _loadComments,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Divider(height: 1),
          ),
          Expanded(
            child: _isLoadingComments
                ? const Center(child: CircularProgressIndicator())
                : _commentsError != null && _comments.isEmpty
                    ? const Center(
                        child: Text(
                          'Unable to load comments.',
                          style: TextStyle(color: Color(0xFF7A828A)),
                        ),
                      )
                    : _comments.isEmpty
                        ? const Center(
                            child: Text(
                              'No comments yet.',
                              style: TextStyle(
                                color: Color(0xFF7A828A),
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: _comments.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment.comment,
                                      style: const TextStyle(
                                        color: Color(0xFF263238),
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      MaterialLocalizations.of(context)
                                          .formatMediumDate(comment.createdAt),
                                      style: const TextStyle(
                                        color: Color(0xFF7A828A),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  String _statementDate(DateTime date) => DateFormat('dd-MM-yyyy').format(date);

  Future<void> _pickStatementDate({required bool startDate}) async {
    final selected = startDate ? _statementStartDate : _statementEndDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (startDate) {
        _statementStartDate = DateUtils.dateOnly(picked);
      } else {
        _statementEndDate = DateUtils.dateOnly(picked);
      }
      _statementError = null;
    });
  }

  Future<void> _generateStatement() async {
    final customerId = widget.customer.id;
    if (customerId == null || customerId.isEmpty) {
      setState(() => _statementError = 'Customer ID is missing.');
      return;
    }
    if (_statementStartDate.isAfter(_statementEndDate)) {
      setState(
          () => _statementError = 'Start date must be on or before end date.');
      return;
    }

    setState(() {
      _isGeneratingStatement = true;
      _statementError = null;
    });
    try {
      final statement = await widget.repository.getCustomerStatement(
        customerId,
        _statementStartDate,
        _statementEndDate,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (_) => _CustomerStatementPreview(
          statement: statement,
          onPrint: () => _printStatement(statement),
          onSendEmail: () => _showStatementEmailDialog(statement),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _statementError = error.toString());
    } finally {
      if (mounted) setState(() => _isGeneratingStatement = false);
    }
  }

  Future<void> _printStatement(CustomerStatement statement) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');
    String amount(double value) => 'INR ${value.toStringAsFixed(2)}';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (_) => [
          pw.Text(
            'Customer Statement',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Text('Statement For: ${statement.customerName}'),
          for (final line in statement.customerAddress) pw.Text(line),
          if (statement.customerEmail.isNotEmpty)
            pw.Text(statement.customerEmail),
          pw.SizedBox(height: 12),
          pw.Text(
            'Statement Period: ${dateFormat.format(statement.startDate)} to ${dateFormat.format(statement.endDate)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headers: const [
              'Date',
              'Type',
              'Document #',
              'Charges (Dr)',
              'Credits (Cr)',
              'Balance',
            ],
            data: [
              [
                '',
                '',
                '',
                '',
                'Opening Balance',
                amount(statement.openingBalance),
              ],
              for (final row in statement.rows)
                [
                  dateFormat.format(row.date),
                  row.type,
                  row.documentNumber,
                  row.charges == 0 ? '-' : amount(row.charges),
                  row.credits == 0 ? '-' : amount(row.credits),
                  amount(row.balance),
                ],
              [
                'Period Totals',
                '',
                '',
                amount(statement.totalCharges),
                amount(statement.totalCredits),
                '',
              ],
              [
                '',
                '',
                '',
                '',
                'Closing Balance',
                amount(statement.closingBalance),
              ],
            ],
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            headerDecoration:
                const pw.BoxDecoration(color: PdfColors.blueGrey900),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(5),
            border: pw.TableBorder.all(color: PdfColors.grey400),
          ),
          pw.SizedBox(height: 18),
          pw.Center(
            child: pw.Text(
              'This is an automatically generated Customer Statement.',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ],
      ),
    );
    try {
      await Printing.layoutPdf(
        name: 'Customer-Statement.pdf',
        onLayout: (_) => pdf.save(),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to print customer statement: $error')),
      );
    }
  }

  Future<void> _showStatementEmailDialog(CustomerStatement statement) async {
    final emailController =
        TextEditingController(text: statement.customerEmail);
    final subjectController = TextEditingController(
      text:
          'Customer Statement - ${statement.customerName} (${DateFormat('dd MMM yyyy').format(statement.startDate)} to ${DateFormat('dd MMM yyyy').format(statement.endDate)})',
    );
    var sending = false;
    String? errorMessage;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Email Statement'),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Recipient Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Color(0xFFAB2A2A)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed:
                    sending ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: sending
                    ? null
                    : () async {
                        setDialogState(() {
                          sending = true;
                          errorMessage = null;
                        });
                        try {
                          await widget.repository.sendCustomerStatementEmail(
                            customerId: widget.customer.id!,
                            startDate: statement.startDate,
                            endDate: statement.endDate,
                            recipientEmail: emailController.text.trim(),
                            subject: subjectController.text.trim(),
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Statement email sent successfully.'),
                            ),
                          );
                        } catch (error) {
                          setDialogState(() {
                            sending = false;
                            errorMessage = error.toString();
                          });
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Email'),
              ),
            ],
          ),
        ),
      );
    } finally {
      emailController.dispose();
      subjectController.dispose();
    }
  }

  Widget _buildStatement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Customer Statement (PDF/HTML)',
            style: TextStyle(
              color: Color(0xFF263238),
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 18,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _statementDateField(
                label: 'Start Date',
                date: _statementStartDate,
                onTap: () => _pickStatementDate(startDate: true),
              ),
              _statementDateField(
                label: 'End Date',
                date: _statementEndDate,
                onTap: () => _pickStatementDate(startDate: false),
              ),
              FilledButton.icon(
                onPressed: _isGeneratingStatement ? null : _generateStatement,
                icon: _isGeneratingStatement
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                  _isGeneratingStatement
                      ? 'Generating...'
                      : 'Generate Statement',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
          if (_statementError != null) ...[
            const SizedBox(height: 12),
            Text(
              _statementError!,
              style: const TextStyle(color: Color(0xFFAB2A2A)),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Click the "Generate Statement" button to open a printable view of the customer transaction history for the selected period.',
            style: TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statementDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 168,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF263238))),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
              ),
              child: Text(_statementDate(date)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    if (_isLoadingTransactions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactionsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unable to load customer transactions.\n$_transactionsError',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFAB2A2A)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final transactions = _transactions!;
    final currency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat('dd MMM yyyy');

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
      children: [
        _TransactionSection(
          title: 'Estimates',
          headers: const ['Date', 'Estimate #', 'Amount', 'Status'],
          rows: transactions.estimates
              .map(
                (item) => [
                  dateFormat.format(item.date),
                  item.number,
                  currency.format(item.amount),
                  item.status,
                ],
              )
              .toList(),
        ),
        _TransactionSection(
          title: 'Sales Orders',
          headers: const ['Date', 'Sales Order #', 'Amount', 'Status'],
          rows: transactions.salesOrders
              .map(
                (item) => [
                  dateFormat.format(item.date),
                  item.number,
                  currency.format(item.amount),
                  item.status,
                ],
              )
              .toList(),
        ),
        _TransactionSection(
          title: 'Invoices',
          headers: const ['Date', 'Invoice #', 'Amount', 'Status'],
          rows: transactions.invoices
              .map(
                (item) => [
                  dateFormat.format(item.date),
                  item.number,
                  currency.format(item.amount),
                  item.status,
                ],
              )
              .toList(),
        ),
        _TransactionSection(
          title: 'Payments Received',
          headers: const [
            'Date',
            'Invoice #',
            'UTR Details',
            'Amount Received'
          ],
          rows: transactions.payments
              .map(
                (item) => [
                  dateFormat.format(item.date),
                  item.invoiceNumber,
                  item.utrReference.isEmpty ? '-' : item.utrReference,
                  currency.format(item.amount),
                ],
              )
              .toList(),
          infoNote: transactions.paymentsAvailable
              ? null
              : 'Payment history is unavailable until the payment_received database table is created. Run the backend database sync to enable it.',
        ),
      ],
    );
  }
}

class _CustomerStatementPreview extends StatelessWidget {
  const _CustomerStatementPreview({
    required this.statement,
    required this.onPrint,
    required this.onSendEmail,
  });

  final CustomerStatement statement;
  final VoidCallback onPrint;
  final VoidCallback onSendEmail;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dateFormat = DateFormat('dd MMM yyyy');
    final reportDate = dateFormat.format(DateTime.now());
    final period =
        '${dateFormat.format(statement.startDate)} to ${dateFormat.format(statement.endDate)}';
    String amount(double value) => 'INR ${value.toStringAsFixed(2)}';
    const headerStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );
    const cellStyle = TextStyle(color: Color(0xFF263238));

    DataCell cell(String text, {bool bold = false}) => DataCell(
          Text(
            text,
            style: bold
                ? cellStyle.copyWith(fontWeight: FontWeight.w700)
                : cellStyle,
          ),
        );

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      child: SizedBox(
        width: screenSize.width < 1040 ? screenSize.width - 40 : 960,
        height: screenSize.height < 760
            ? screenSize.height - 40
            : screenSize.height * .9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 16, 14),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Customer Statement',
                      style: TextStyle(
                        color: Color(0xFF173A5E),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Statement For:',
                                style: cellStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                statement.customerName,
                                style: cellStyle.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              for (final addressLine
                                  in statement.customerAddress)
                                Text(addressLine, style: cellStyle),
                              if (statement.customerEmail.isNotEmpty)
                                Text(statement.customerEmail, style: cellStyle),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Report Date: $reportDate', style: cellStyle),
                            const Text('Currency: INR', style: cellStyle),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F1F2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Statement Period: $period',
                        style: cellStyle.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor:
                            const WidgetStatePropertyAll(Color(0xFF123456)),
                        border: TableBorder.all(
                          color: const Color(0xFFD6DCE1),
                        ),
                        columns: const [
                          DataColumn(label: Text('Date', style: headerStyle)),
                          DataColumn(label: Text('Type', style: headerStyle)),
                          DataColumn(
                            label: Text('Document #', style: headerStyle),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text('Charges (Dr)', style: headerStyle),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text('Credits (Cr)', style: headerStyle),
                          ),
                          DataColumn(
                            numeric: true,
                            label: Text('Balance', style: headerStyle),
                          ),
                        ],
                        rows: [
                          DataRow(
                            color: const WidgetStatePropertyAll(
                              Color(0xFFE5F6FF),
                            ),
                            cells: [
                              cell(''),
                              cell(''),
                              cell('Opening Balance', bold: true),
                              cell(''),
                              cell(''),
                              cell(amount(statement.openingBalance),
                                  bold: true),
                            ],
                          ),
                          for (final row in statement.rows)
                            DataRow(cells: [
                              cell(dateFormat.format(row.date)),
                              cell(row.type),
                              cell(row.documentNumber),
                              cell(
                                  row.charges == 0 ? '-' : amount(row.charges)),
                              cell(
                                  row.credits == 0 ? '-' : amount(row.credits)),
                              cell(amount(row.balance)),
                            ]),
                          DataRow(
                            color: const WidgetStatePropertyAll(
                              Color(0xFFE5F6FF),
                            ),
                            cells: [
                              cell('Period Totals', bold: true),
                              cell(''),
                              cell(''),
                              cell(amount(statement.totalCharges), bold: true),
                              cell(amount(statement.totalCredits), bold: true),
                              cell(''),
                            ],
                          ),
                          DataRow(
                            color: const WidgetStatePropertyAll(
                              Color(0xFFB6E0FA),
                            ),
                            cells: [
                              cell(''),
                              cell(''),
                              cell(
                                  'Closing Balance as of ${dateFormat.format(statement.endDate)}',
                                  bold: true),
                              cell(''),
                              cell(''),
                              cell(amount(statement.closingBalance),
                                  bold: true),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'This is an automatically generated Customer Statement.',
                        style: TextStyle(
                          color: Color(0xFF7A828A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print / Save as PDF'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onSendEmail,
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Send via Email'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionSection extends StatelessWidget {
  const _TransactionSection({
    required this.title,
    required this.headers,
    required this.rows,
    this.infoNote,
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;
  final String? infoNote;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF123456),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 14),
            child: Divider(height: 1, color: Color(0xFF3498DB)),
          ),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No records found.',
                style: TextStyle(color: Color(0xFF7A828A)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final minWidth =
                    constraints.maxWidth < 650 ? 650.0 : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: minWidth,
                    child: DataTable(
                      headingRowColor: const WidgetStatePropertyAll(
                        Color(0xFFF7F8FA),
                      ),
                      border: TableBorder.all(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      columns: headers
                          .map(
                            (header) => DataColumn(
                              label: Text(
                                header,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF263238),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      rows: rows
                          .map(
                            (row) => DataRow(
                              cells: row
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => DataCell(
                                      entry.key == row.length - 1 &&
                                              headers.last == 'Status'
                                          ? _TransactionStatus(
                                              status: entry.value,
                                            )
                                          : Text(
                                              entry.value,
                                              style: const TextStyle(
                                                color: Color(0xFF263238),
                                              ),
                                            ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          if (infoNote != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                infoNote!,
                style: const TextStyle(color: Color(0xFF8A5A00)),
              ),
            ),
        ],
      ),
    );
  }
}

class _TransactionStatus extends StatelessWidget {
  const _TransactionStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = normalized == 'paid' ||
            normalized == 'invoiced' ||
            normalized == 'approved' ||
            normalized == 'sent'
        ? const Color(0xFF1E9B62)
        : normalized == 'void' ||
                normalized == 'declined' ||
                normalized == 'rejected' ||
                normalized == 'cancelled'
            ? const Color(0xFFAB2A2A)
            : const Color(0xFF68727C);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7A828A),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF263238),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
