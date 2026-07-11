import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/evento.dart';
import '../view_model/calendario_view_model.dart';

class CalendarioWidget extends StatefulWidget {
  const CalendarioWidget({super.key});

  @override
  State<CalendarioWidget> createState() => _CalendarioWidgetState();
}

class _CalendarioWidgetState extends State<CalendarioWidget> {
  DateTime _focusedDay = DateTime.now();

  void _showMonthYearPicker(BuildContext context, DateTime currentFocusedDay) {
    int selectedMonth = currentFocusedDay.month;
    int selectedYear = currentFocusedDay.year;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annulla', style: TextStyle(color: Colors.grey)),
                    ),
                    const Text('Seleziona Mese', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(selectedYear, selectedMonth, 1);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Fatto', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF25315B))),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedMonth - 1),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          selectedMonth = index + 1;
                        },
                        children: List.generate(12, (index) {
                          final mese = DateFormat('MMMM', 'it_IT').format(DateTime(2020, index + 1));
                          return Center(child: Text("${mese[0].toUpperCase()}${mese.substring(1)}"));
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(initialItem: selectedYear - 1940),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          selectedYear = 1940 + index;
                        },
                        children: List.generate(161, (index) { // Da 1940 a 2100 (161 anni)
                          return Center(child: Text('${1940 + index}'));
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CalendarioViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        daysOfWeekHeight: 30.0,
        locale: 'it_IT',
        firstDay: DateTime.utc(1940, 1, 1),
        lastDay: DateTime.utc(2100, 12, 31),
        focusedDay: _focusedDay,
        onHeaderTapped: (focusedDay) {
          _showMonthYearPicker(context, focusedDay);
        },
        eventLoader: (day) => viewModel.getEventiForDay(day),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isEmpty) return const SizedBox();

            final multiDayEvents = events.where((e) => e is Evento && (
              e.dataInizio.year != e.dataFine.year ||
              e.dataInizio.month != e.dataFine.month ||
              e.dataInizio.day != e.dataFine.day
            )).cast<Evento>().toList();

            final singleDayEvents = events.where((e) => e is Evento && !(
              e.dataInizio.year != e.dataFine.year ||
              e.dataInizio.month != e.dataFine.month ||
              e.dataInizio.day != e.dataFine.day
            )).cast<Evento>().toList();

            final List<Widget> children = [];

            if (multiDayEvents.isNotEmpty) {
              final e = multiDayEvents.first;
              final isStart = isSameDay(date, e.dataInizio);
              final isEnd = isSameDay(date, e.dataFine);

              children.add(
                Positioned(
                  bottom: 2,
                  left: isStart ? 4 : 0,
                  right: isEnd ? 4 : 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: e.colorePrincipale,
                      borderRadius: BorderRadius.only(
                        topLeft: isStart ? const Radius.circular(4) : Radius.zero,
                        bottomLeft: isStart ? const Radius.circular(4) : Radius.zero,
                        topRight: isEnd ? const Radius.circular(4) : Radius.zero,
                        bottomRight: isEnd ? const Radius.circular(4) : Radius.zero,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (singleDayEvents.isNotEmpty) {
              children.add(
                Positioned(
                  bottom: multiDayEvents.isNotEmpty ? 8 : 2,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: singleDayEvents.map((e) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1.0),
                      width: 5.0,
                      height: 5.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: e.colorePrincipale,
                      ),
                    )).toList(),
                  ),
                ),
              );
            }

            return Stack(
              clipBehavior: Clip.none,
              children: children,
            );
          },
        ),
        selectedDayPredicate: (day) {
          return isSameDay(viewModel.selectedDate, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(viewModel.selectedDate, selectedDay)) {
            viewModel.setSelectedDate(selectedDay);
            setState(() {
              _focusedDay = focusedDay;
            });
          }
        },
        onPageChanged: (focusedDay) {
          setState(() {
            _focusedDay = focusedDay;
          });
        },
        calendarStyle: CalendarStyle(
          isTodayHighlighted: true, 
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF25315B), // Blu scuro Jamb
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: const Color(0xFF25315B).withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
          defaultTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          weekendTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          outsideTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B).withOpacity(0.3),
          ),
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          leftChevronIcon: Icon(Icons.chevron_left, color: Color(0xFF25315B)),
          rightChevronIcon: Icon(Icons.chevron_right, color: Color(0xFF25315B)),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: Color(0xFF94A3B8), 
            fontWeight: FontWeight.bold,
          ),
          weekendStyle: TextStyle(
            color: Color(0xFF94A3B8), 
            fontWeight: FontWeight.bold,
          ),
        ),
        startingDayOfWeek: StartingDayOfWeek.monday,
      ),
    );
  }
}
