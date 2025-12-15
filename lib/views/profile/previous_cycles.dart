import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/cycle_history.dart';
import '../../main.dart';

class PreviousCyclesPage extends StatefulWidget {
  const PreviousCyclesPage({super.key});

  @override
  State<PreviousCyclesPage> createState() => _PreviousCyclesPageState();
}

class _PreviousCyclesPageState extends State<PreviousCyclesPage> {
  late List<CycleHistoryEntry> _cycles;
  bool _isLoading = false;
  final _startDateController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _periodLengthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCycles();
  }

  Future<void> _loadCycles() async {
    setState(() => _isLoading = true);
    try {
      await CycleHistoryData.loadCycles();
      if (mounted) {
        setState(() {
          _cycles = List.from(CycleHistoryData.recentCycles);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        appScaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error loading cycles: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  void _addCycle() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Previous Cycle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Start Date Field
              TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Cycle Start Date',
                  hintText: 'Select a date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDateController.text =
                          DateFormat('MM/dd/yyyy').format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Cycle Length Field
              TextField(
                controller: _cycleLengthController,
                decoration: InputDecoration(
                  labelText: 'Cycle Length (days)',
                  hintText: 'e.g., 28',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Period Length Field
              TextField(
                controller: _periodLengthController,
                decoration: InputDecoration(
                  labelText: 'Period Length (days)',
                  hintText: 'e.g., 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _startDateController.clear();
              _cycleLengthController.clear();
              _periodLengthController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_startDateController.text.isEmpty ||
                  _cycleLengthController.text.isEmpty ||
                  _periodLengthController.text.isEmpty) {
                appScaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              try {
                final startDate = DateFormat('MM/dd/yyyy')
                    .parse(_startDateController.text);
                final cycleLength = int.parse(_cycleLengthController.text);
                final periodLength = int.parse(_periodLengthController.text);

                if (cycleLength <= 0 || periodLength <= 0) {
                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Values must be greater than 0'),
                    ),
                  );
                  return;
                }

                final newCycle = CycleHistoryEntry(
                  startDate: startDate,
                  cycleLengthDays: cycleLength,
                  periodLengthDays: periodLength,
                );

                // Save to Firebase
                await CycleHistoryData.addCycle(newCycle);

                if (mounted) {
                  setState(() {
                    _cycles = List.from(CycleHistoryData.recentCycles);
                  });

                  _startDateController.clear();
                  _cycleLengthController.clear();
                  _periodLengthController.clear();

                  Navigator.pop(context);

                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Cycle added successfully'),
                    ),
                  );
                }
              } catch (e) {
                appScaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946A6),
            ),
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _editCycle(int index) {
    final cycle = _cycles[index];
    _startDateController.text =
        DateFormat('MM/dd/yyyy').format(cycle.startDate);
    _cycleLengthController.text = cycle.cycleLengthDays.toString();
    _periodLengthController.text = cycle.periodLengthDays.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Cycle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Start Date Field
              TextField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Cycle Start Date',
                  hintText: 'Select a date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: cycle.startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDateController.text =
                          DateFormat('MM/dd/yyyy').format(picked);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // Cycle Length Field
              TextField(
                controller: _cycleLengthController,
                decoration: InputDecoration(
                  labelText: 'Cycle Length (days)',
                  hintText: 'e.g., 28',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Period Length Field
              TextField(
                controller: _periodLengthController,
                decoration: InputDecoration(
                  labelText: 'Period Length (days)',
                  hintText: 'e.g., 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _startDateController.clear();
              _cycleLengthController.clear();
              _periodLengthController.clear();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete the cycle
              try {
                await CycleHistoryData.removeCycle(index);

                if (mounted) {
                  setState(() {
                    _cycles = List.from(CycleHistoryData.recentCycles);
                  });

                  _startDateController.clear();
                  _cycleLengthController.clear();
                  _periodLengthController.clear();

                  Navigator.pop(context);

                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Cycle deleted'),
                    ),
                  );
                }
              } catch (e) {
                appScaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Error deleting cycle: $e'),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_startDateController.text.isEmpty ||
                  _cycleLengthController.text.isEmpty ||
                  _periodLengthController.text.isEmpty) {
                appScaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                  ),
                );
                return;
              }

              try {
                final startDate = DateFormat('MM/dd/yyyy')
                    .parse(_startDateController.text);
                final cycleLength = int.parse(_cycleLengthController.text);
                final periodLength = int.parse(_periodLengthController.text);

                if (cycleLength <= 0 || periodLength <= 0) {
                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Values must be greater than 0'),
                    ),
                  );
                  return;
                }

                final updatedCycle = CycleHistoryEntry(
                  id: _cycles[index].id,
                  startDate: startDate,
                  cycleLengthDays: cycleLength,
                  periodLengthDays: periodLength,
                );

                await CycleHistoryData.updateCycle(index, updatedCycle);

                if (mounted) {
                  setState(() {
                    _cycles = List.from(CycleHistoryData.recentCycles);
                  });

                  _startDateController.clear();
                  _cycleLengthController.clear();
                  _periodLengthController.clear();

                  Navigator.pop(context);

                  appScaffoldMessengerKey.currentState?.showSnackBar(
                    const SnackBar(
                      content: Text('Cycle updated successfully'),
                    ),
                  );
                }
              } catch (e) {
                appScaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946A6),
            ),
            child: const Text(
              'Update',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Previous Cycles'),
        backgroundColor: const Color(0xFFD946A6),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cycles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No previous cycles recorded',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cycles.length,
                  itemBuilder: (context, index) {
                    final cycle = _cycles[index];
                    final periodEndDate = cycle.startDate
                        .add(Duration(days: cycle.periodLengthDays - 1));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          'Cycle ${_cycles.length - index}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(
                              'Start: ${DateFormat('MMM d, yyyy').format(cycle.startDate)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Period: ${DateFormat('MMM d').format(cycle.startDate)} - ${DateFormat('MMM d, yyyy').format(periodEndDate)}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              'Cycle: ${cycle.cycleLengthDays} days | Period: ${cycle.periodLengthDays} days',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFD946A6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          color: const Color(0xFFD946A6),
                          onPressed: () {
                            _editCycle(index);
                          },
                        ),
                        onTap: () {
                          _editCycle(index);
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCycle,
        backgroundColor: const Color(0xFFD946A6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
