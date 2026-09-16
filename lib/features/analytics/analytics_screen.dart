import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_formatter.dart';
import 'analytics_state.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Statistiques',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Votre progression de concentration',
                  style: GoogleFonts.plusJakartaSans(
                      color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              _StatsGrid(analytics: analytics),
              const SizedBox(height: 24),
              _DailyChart(dailyMinutes: analytics.dailyMinutes),
              const SizedBox(height: 24),
              _CategoryChart(categoryMinutes: analytics.categoryMinutes),
              const SizedBox(height: 24),
              _RecentSessions(sessions: analytics.recentSessions),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AnalyticsData analytics;

  const _StatsGrid({required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      _StatCard(
        icon: Icons.timer,
        label: 'Temps total',
        value: analytics.formattedTotalFocus,
        color: theme.colorScheme.primary,
      ),
      _StatCard(
        icon: Icons.check_circle,
        label: 'Sessions',
        value: analytics.totalSessions.toString(),
        color: Colors.green,
      ),
      _StatCard(
        icon: Icons.local_fire_department,
        label: 'Série',
        value: analytics.formattedStreak,
        color: Colors.orange,
      ),
      _StatCard(
        icon: Icons.trending_up,
        label: 'Taux réussite',
        value: analytics.formattedCompletionRate,
        color: Colors.blue,
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 24, fontWeight: FontWeight.w700, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyChart extends StatelessWidget {
  final Map<DateTime, int> dailyMinutes;

  const _DailyChart({required this.dailyMinutes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last7Days = getLastNDays(7);
    final spots = last7Days.map((day) {
      final minutes = (dailyMinutes[day] ?? 0) / 60.0;
      return FlSpot(last7Days.indexOf(day).toDouble(), minutes);
    }).toList();

    return Semantics(
      label: 'Graphique des 7 derniers jours',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('7 derniers jours',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (v) =>
                            FlLine(color: theme.dividerColor)),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (v, _) => Text('${v.toInt()}h',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10)))),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) =>
                                  v.toInt() < last7Days.length
                                      ? Text(formatDay(last7Days[v.toInt()]),
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 10))
                                      : const Text(''))),
                      topTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: theme.colorScheme.primary,
                        barWidth: 3,
                        dotData: FlDotData(
                            getDotPainter: (spot, _, __, ___) =>
                                FlDotCirclePainter(
                                    radius: 4,
                                    color: theme.colorScheme.primary)),
                        belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withOpacity(0.1)),
                      ),
                    ],
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, int> categoryMinutes;

  const _CategoryChart({required this.categoryMinutes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = categoryMinutes.entries.toList();
    final total = entries.fold(0, (sum, e) => sum + e.value);

    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: Text('Aucune donnée',
                  style: GoogleFonts.plusJakartaSans(
                      color: theme.colorScheme.onSurfaceVariant))),
        ),
      );
    }

    return Semantics(
      label: 'Répartition par catégorie',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Par catégorie',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: entries.asMap().entries.map((e) {
                      final index = e.key;
                      final entry = e.value;
                      final percentage =
                          total > 0 ? (entry.value / total * 100) : 0.0;
                      final colors = [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                        theme.colorScheme.tertiary,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                      ];
                      return PieChartSectionData(
                        value: entry.value.toDouble(),
                        title: '${percentage.toStringAsFixed(0)}%',
                        color: colors[index % colors.length],
                        radius: 80,
                        titleStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                        badgeWidget: Text(entry.key,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: colors[index % colors.length])),
                        badgePositionPercentageOffset: 1.3,
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: entries.asMap().entries.map((e) {
                  final index = e.key;
                  final entry = e.value;
                  final colors = [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                  ];
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(
                          '${entry.key}: ${formatDurationLong(entry.value * 60)}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentSessions extends StatelessWidget {
  final List<SessionRecord> sessions;

  const _RecentSessions({required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (sessions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
              child: Text('Aucune session récente',
                  style: GoogleFonts.plusJakartaSans(
                      color: theme.colorScheme.onSurfaceVariant))),
        ),
      );
    }

    return Semantics(
      label: 'Sessions récentes',
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Sessions récentes',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: theme.dividerColor),
              itemBuilder: (context, index) {
                final s = sessions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      s.mode == TimerMode.work
                          ? Icons.center_focus_strong
                          : Icons.coffee,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(s.category,
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(formatDateTime(s.timestamp),
                      style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                  trailing: Text(
                    formatDuration(s.durationSeconds),
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
