import re

with open(r'lib\screens\analytics_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove ThemeProvider import
content = content.replace("import 'package:smart_energy_controller/providers/theme_provider.dart';\n", '')

# Remove themeProvider declaration in build
content = content.replace('    final themeProvider = Provider.of<ThemeProvider>(context);\n', '')

# Fix method calls - remove themeProvider argument
replacements = [
    ('_buildPowerTab(hourlyData, stats, themeProvider)', '_buildPowerTab(hourlyData, stats)'),
    ('_buildEnergyTab(stats, themeProvider)', '_buildEnergyTab(stats)'),
    ('_buildSavingsTab(stats, themeProvider)', '_buildSavingsTab(stats)'),
    ('_buildPowerChart(hourlyData, themeProvider)', '_buildPowerChart(hourlyData)'),
    ('_buildVoltageChart(hourlyData, themeProvider)', '_buildVoltageChart(hourlyData)'),
    ('_buildCurrentChart(hourlyData, themeProvider)', '_buildCurrentChart(hourlyData)'),
    ('_buildPeakHoursCard(hourlyData, themeProvider)', '_buildPeakHoursCard(hourlyData)'),
    ('_buildKeyMetricsGrid(stats, themeProvider)', '_buildKeyMetricsGrid(stats)'),
    ('_buildEnergySourcesCard(stats, themeProvider)', '_buildEnergySourcesCard(stats)'),
    ('_buildEfficiencyMetricsCard(stats, themeProvider)', '_buildEfficiencyMetricsCard(stats)'),
    ('_buildSavingsOverviewCard(moneySaved, savingsPercentage, themeProvider)', '_buildSavingsOverviewCard(moneySaved, savingsPercentage)'),
    ('_buildEnvironmentalImpactCard(co2Saved, treesEquivalent, themeProvider)', '_buildEnvironmentalImpactCard(co2Saved, treesEquivalent)'),
    ('_buildCostBreakdownChart(moneyUsed, moneySaved, themeProvider)', '_buildCostBreakdownChart(moneyUsed, moneySaved)'),
    ('_buildSavingsTimelineCard(themeProvider)', '_buildSavingsTimelineCard()'),
    ('_buildROICalculatorCard(stats, themeProvider)', '_buildROICalculatorCard(stats)'),
    ('_buildEnergyProductionChart(themeProvider)', '_buildEnergyProductionChart()'),
]

for old, new in replacements:
    content = content.replace(old, new)

# Fix _buildEnergyDistributionChart call (multiline)
content = re.sub(
    r'_buildEnergyDistributionChart\(\s*solarPercentage,\s*gridPercentage,\s*themeProvider,\s*\)',
    '_buildEnergyDistributionChart(\n                solarPercentage,\n                gridPercentage,\n              )',
    content
)

# Fix method signatures - remove ThemeProvider themeProvider parameter
sig_replacements = [
    ('Widget _buildEnergyTab(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildEnergyTab(DailyStats? stats)'),
    ('Widget _buildSavingsTab(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildSavingsTab(DailyStats? stats)'),
    ('Widget _buildPowerChart(List<HourlyData> data, ThemeProvider themeProvider)', 'Widget _buildPowerChart(List<HourlyData> data)'),
    ('Widget _buildVoltageChart(List<HourlyData> data, ThemeProvider themeProvider)', 'Widget _buildVoltageChart(List<HourlyData> data)'),
    ('Widget _buildCurrentChart(List<HourlyData> data, ThemeProvider themeProvider)', 'Widget _buildCurrentChart(List<HourlyData> data)'),
    ('Widget _buildEnergyProductionChart(ThemeProvider themeProvider)', 'Widget _buildEnergyProductionChart()'),
    ('Widget _buildCostBreakdownChart(double used, double saved, ThemeProvider themeProvider)', 'Widget _buildCostBreakdownChart(double used, double saved)'),
    ('Widget _buildPeakHoursCard(List<HourlyData> data, ThemeProvider themeProvider)', 'Widget _buildPeakHoursCard(List<HourlyData> data)'),
    ('Widget _buildKeyMetricsGrid(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildKeyMetricsGrid(DailyStats? stats)'),
    ('Widget _buildEnergySourcesCard(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildEnergySourcesCard(DailyStats? stats)'),
    ('Widget _buildEfficiencyMetricsCard(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildEfficiencyMetricsCard(DailyStats? stats)'),
    ('Widget _buildSavingsOverviewCard(double saved, double percentage, ThemeProvider themeProvider)', 'Widget _buildSavingsOverviewCard(double saved, double percentage)'),
    ('Widget _buildEnvironmentalImpactCard(double co2Saved, double treesEquivalent, ThemeProvider themeProvider)', 'Widget _buildEnvironmentalImpactCard(double co2Saved, double treesEquivalent)'),
    ('Widget _buildSavingsTimelineCard(ThemeProvider themeProvider)', 'Widget _buildSavingsTimelineCard()'),
    ('Widget _buildROICalculatorCard(DailyStats? stats, ThemeProvider themeProvider)', 'Widget _buildROICalculatorCard(DailyStats? stats)'),
]

for old, new in sig_replacements:
    content = content.replace(old, new)

# Fix _buildPowerTab signature (multiline)
content = re.sub(
    r'Widget _buildPowerTab\(\s*List<HourlyData> hourlyData,\s*DailyStats\? stats,\s*ThemeProvider themeProvider,\s*\)',
    'Widget _buildPowerTab(\n    List<HourlyData> hourlyData,\n    DailyStats? stats,\n  )',
    content
)

# Fix _buildEnergyDistributionChart signature (multiline)
content = re.sub(
    r'Widget _buildEnergyDistributionChart\(\s*double solarPercentage,\s*double gridPercentage,\s*ThemeProvider themeProvider,\s*\)',
    'Widget _buildEnergyDistributionChart(\n    double solarPercentage,\n    double gridPercentage,\n  )',
    content
)

with open(r'lib\screens\analytics_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('Done - analytics_screen.dart fixed')
