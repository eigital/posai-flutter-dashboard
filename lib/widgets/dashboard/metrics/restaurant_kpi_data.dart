// Mirrors [eatos-live-dashboard/src/lib/restaurant-kpi-types.ts] and [generateRestaurantKPIs].

import 'kpi_formatting.dart';

class BenchmarkTargets {
  const BenchmarkTargets({
    required this.min,
    required this.max,
    required this.ideal,
  });

  final double min;
  final double max;
  final double ideal;

  BenchmarkBand get band => (min: min, max: max, ideal: ideal);
}

class IndustryBenchmarksData {
  const IndustryBenchmarksData({
    required this.foodCostTarget,
    required this.laborCostTarget,
    required this.primeCostTarget,
    required this.rentTarget,
    required this.profitMarginTarget,
  });

  final BenchmarkTargets foodCostTarget;
  final BenchmarkTargets laborCostTarget;
  final BenchmarkTargets primeCostTarget;
  final BenchmarkTargets rentTarget;
  final BenchmarkTargets profitMarginTarget;
}

/// Same numeric values as [INDUSTRY_BENCHMARKS] in TS.
const IndustryBenchmarksData kIndustryBenchmarks = IndustryBenchmarksData(
  foodCostTarget: BenchmarkTargets(min: 28, max: 32, ideal: 30),
  laborCostTarget: BenchmarkTargets(min: 25, max: 35, ideal: 30),
  primeCostTarget: BenchmarkTargets(min: 60, max: 65, ideal: 62),
  rentTarget: BenchmarkTargets(min: 6, max: 10, ideal: 8),
  profitMarginTarget: BenchmarkTargets(min: 3, max: 9, ideal: 6),
);

class SalesPeriodPrev {
  const SalesPeriodPrev({
    required this.netSales,
    required this.grossSales,
    required this.averageOrderValue,
    required this.customerCount,
  });

  final double netSales;
  final double grossSales;
  final double averageOrderValue;
  final int customerCount;
}

class SalesMetricsData {
  const SalesMetricsData({
    required this.netSales,
    required this.grossSales,
    required this.averageOrderValue,
    required this.salesPerSquareFoot,
    required this.customerCount,
    required this.averageSpendPerCustomer,
    required this.revenuePASH,
    required this.previousPeriod,
  });

  final double netSales;
  final double grossSales;
  final double averageOrderValue;
  final double salesPerSquareFoot;
  final int customerCount;
  final double averageSpendPerCustomer;
  final double revenuePASH;
  final SalesPeriodPrev previousPeriod;
}

class LaborPeriodPrev {
  const LaborPeriodPrev({
    required this.totalLaborCost,
    required this.laborCostPercentage,
    required this.salesPerLaborHour,
  });

  final double totalLaborCost;
  final double laborCostPercentage;
  final double salesPerLaborHour;
}

class LaborMetricsData {
  const LaborMetricsData({
    required this.totalLaborCost,
    required this.laborCostPercentage,
    required this.productiveLaborHours,
    required this.nonProductiveLaborHours,
    required this.salesPerLaborHour,
    required this.laborCostPerCustomer,
    required this.staffEfficiencyScore,
    required this.overtimeHours,
    required this.overtimeCost,
    required this.scheduledVsActualHours,
    required this.previousPeriod,
  });

  final double totalLaborCost;
  final double laborCostPercentage;
  final double productiveLaborHours;
  final double nonProductiveLaborHours;
  final double salesPerLaborHour;
  final double laborCostPerCustomer;
  final double staffEfficiencyScore;
  final double overtimeHours;
  final double overtimeCost;
  final double scheduledVsActualHours;
  final LaborPeriodPrev previousPeriod;
}

enum MenuItemClassification { star, plowHorse, puzzle, dog }

class MenuItemData {
  const MenuItemData({
    required this.id,
    required this.name,
    required this.category,
    required this.unitsSold,
    required this.revenue,
    required this.costOfGoods,
    required this.profitMargin,
    required this.contributionMargin,
    required this.popularity,
    required this.profitability,
    required this.classification,
    required this.pricePoint,
    required this.preparationTime,
  });

  final String id;
  final String name;
  final String category;
  final int unitsSold;
  final double revenue;
  final double costOfGoods;
  final double profitMargin;
  final double contributionMargin;
  final double popularity;
  final double profitability;
  final MenuItemClassification classification;
  final double pricePoint;
  final int preparationTime;
}

class MenuEngineeringData {
  const MenuEngineeringData({
    required this.stars,
    required this.plowHorses,
    required this.puzzles,
    required this.dogs,
  });

  final List<MenuItemData> stars;
  final List<MenuItemData> plowHorses;
  final List<MenuItemData> puzzles;
  final List<MenuItemData> dogs;
}

class ItemsMetricsData {
  const ItemsMetricsData({
    required this.bestSellingItems,
    required this.worstSellingItems,
    required this.menuEngineering,
    required this.categoryMix,
    required this.averageItemProfitMargin,
    required this.menuMixAnalysis,
    required this.priceElasticity,
  });

  final List<MenuItemData> bestSellingItems;
  final List<MenuItemData> worstSellingItems;
  final MenuEngineeringData menuEngineering;
  final Map<String, double> categoryMix;
  final double averageItemProfitMargin;
  final Map<String, double> menuMixAnalysis;
  final Map<String, double> priceElasticity;
}

class FoodCostPeriodPrev {
  const FoodCostPeriodPrev({
    required this.foodCostPercentage,
    required this.costOfGoodsSold,
    required this.foodWastePercentage,
  });

  final double foodCostPercentage;
  final double costOfGoodsSold;
  final double foodWastePercentage;
}

class FoodCostMetricsData {
  const FoodCostMetricsData({
    required this.foodCostPercentage,
    required this.costOfGoodsSold,
    required this.foodWastePercentage,
    required this.inventoryTurnoverRate,
    required this.theoreticalVsActualFoodCost,
    required this.vendorCostTrends,
    required this.averageRecipeCost,
    required this.previousPeriod,
  });

  final double foodCostPercentage;
  final double costOfGoodsSold;
  final double foodWastePercentage;
  final double inventoryTurnoverRate;
  final double theoreticalVsActualFoodCost;
  final Map<String, List<double>> vendorCostTrends;
  final double averageRecipeCost;
  final FoodCostPeriodPrev previousPeriod;
}

class FixedCostPeriodPrev {
  const FixedCostPeriodPrev({
    required this.rentPercentage,
    required this.utilitiesCost,
    required this.totalFixedCosts,
  });

  final double rentPercentage;
  final double utilitiesCost;
  final double totalFixedCosts;
}

class FixedCostMetricsData {
  const FixedCostMetricsData({
    required this.rentPercentage,
    required this.utilitiesCost,
    required this.insuranceCost,
    required this.licenseCost,
    required this.equipmentDepreciation,
    required this.marketingSpend,
    required this.marketingROI,
    required this.administrativeCosts,
    required this.totalFixedCosts,
    required this.previousPeriod,
  });

  final double rentPercentage;
  final double utilitiesCost;
  final double insuranceCost;
  final double licenseCost;
  final double equipmentDepreciation;
  final double marketingSpend;
  final double marketingROI;
  final double administrativeCosts;
  final double totalFixedCosts;
  final FixedCostPeriodPrev previousPeriod;
}

class RestaurantKpiBundle {
  const RestaurantKpiBundle({
    required this.sales,
    required this.labor,
    required this.items,
    required this.foodCost,
    required this.fixedCost,
    required this.benchmarks,
  });

  final SalesMetricsData sales;
  final LaborMetricsData labor;
  final ItemsMetricsData items;
  final FoodCostMetricsData foodCost;
  final FixedCostMetricsData fixedCost;
  final IndustryBenchmarksData benchmarks;

  /// Same structure as [generateRestaurantKPIs] in TS.
  static RestaurantKpiBundle generate() {
    const menuItems = <MenuItemData>[
      MenuItemData(
        id: '1',
        name: 'Classic Burger',
        category: 'Burgers',
        unitsSold: 156,
        revenue: 2184,
        costOfGoods: 655.2,
        profitMargin: 70,
        contributionMargin: 1528.8,
        popularity: 85,
        profitability: 88,
        classification: MenuItemClassification.star,
        pricePoint: 14,
        preparationTime: 8,
      ),
      MenuItemData(
        id: '2',
        name: 'Caesar Salad',
        category: 'Salads',
        unitsSold: 89,
        revenue: 1068,
        costOfGoods: 298.48,
        profitMargin: 72,
        contributionMargin: 769.52,
        popularity: 45,
        profitability: 92,
        classification: MenuItemClassification.puzzle,
        pricePoint: 12,
        preparationTime: 5,
      ),
      MenuItemData(
        id: '3',
        name: 'Margherita Pizza',
        category: 'Pizza',
        unitsSold: 203,
        revenue: 3248,
        costOfGoods: 974.4,
        profitMargin: 70,
        contributionMargin: 2273.6,
        popularity: 95,
        profitability: 85,
        classification: MenuItemClassification.star,
        pricePoint: 16,
        preparationTime: 12,
      ),
      MenuItemData(
        id: '4',
        name: 'Fish & Chips',
        category: 'Seafood',
        unitsSold: 34,
        revenue: 612,
        costOfGoods: 214.2,
        profitMargin: 65,
        contributionMargin: 397.8,
        popularity: 25,
        profitability: 78,
        classification: MenuItemClassification.dog,
        pricePoint: 18,
        preparationTime: 15,
      ),
      MenuItemData(
        id: '5',
        name: 'Chicken Wings',
        category: 'Appetizers',
        unitsSold: 127,
        revenue: 1651,
        costOfGoods: 528.32,
        profitMargin: 68,
        contributionMargin: 1122.68,
        popularity: 78,
        profitability: 62,
        classification: MenuItemClassification.plowHorse,
        pricePoint: 13,
        preparationTime: 10,
      ),
      MenuItemData(
        id: '6',
        name: 'Ribeye Steak',
        category: 'Steaks',
        unitsSold: 23,
        revenue: 1058,
        costOfGoods: 423.2,
        profitMargin: 60,
        contributionMargin: 634.8,
        popularity: 15,
        profitability: 95,
        classification: MenuItemClassification.puzzle,
        pricePoint: 46,
        preparationTime: 20,
      ),
      MenuItemData(
        id: '7',
        name: 'Pasta Carbonara',
        category: 'Pasta',
        unitsSold: 78,
        revenue: 1404,
        costOfGoods: 421.2,
        profitMargin: 70,
        contributionMargin: 982.8,
        popularity: 65,
        profitability: 75,
        classification: MenuItemClassification.plowHorse,
        pricePoint: 18,
        preparationTime: 12,
      ),
      MenuItemData(
        id: '8',
        name: 'Craft Beer',
        category: 'Beverages',
        unitsSold: 234,
        revenue: 1638,
        costOfGoods: 409.5,
        profitMargin: 75,
        contributionMargin: 1228.5,
        popularity: 88,
        profitability: 68,
        classification: MenuItemClassification.plowHorse,
        pricePoint: 7,
        preparationTime: 1,
      ),
    ];

    final sortedByUnits = List<MenuItemData>.from(menuItems)..sort((a, b) => b.unitsSold.compareTo(a.unitsSold));

    return RestaurantKpiBundle(
      benchmarks: kIndustryBenchmarks,
      sales: SalesMetricsData(
        netSales: 45280.50,
        grossSales: 47850.25,
        averageOrderValue: 38.75,
        salesPerSquareFoot: 285.50,
        customerCount: 1235,
        averageSpendPerCustomer: 36.68,
        revenuePASH: 142.25,
        previousPeriod: const SalesPeriodPrev(
          netSales: 42150.25,
          grossSales: 44680.75,
          averageOrderValue: 35.50,
          customerCount: 1187,
        ),
      ),
      labor: LaborMetricsData(
        totalLaborCost: 13584.15,
        laborCostPercentage: 30.0,
        productiveLaborHours: 425.5,
        nonProductiveLaborHours: 32.25,
        salesPerLaborHour: 106.42,
        laborCostPerCustomer: 11.00,
        staffEfficiencyScore: 87.5,
        overtimeHours: 18.5,
        overtimeCost: 462.50,
        scheduledVsActualHours: 3.2,
        previousPeriod: const LaborPeriodPrev(
          totalLaborCost: 12965.85,
          laborCostPercentage: 30.8,
          salesPerLaborHour: 98.75,
        ),
      ),
      items: ItemsMetricsData(
        bestSellingItems: sortedByUnits.take(5).toList(),
        worstSellingItems: sortedByUnits.sublist(sortedByUnits.length - 3),
        menuEngineering: MenuEngineeringData(
          stars: menuItems.where((e) => e.classification == MenuItemClassification.star).toList(),
          plowHorses: menuItems.where((e) => e.classification == MenuItemClassification.plowHorse).toList(),
          puzzles: menuItems.where((e) => e.classification == MenuItemClassification.puzzle).toList(),
          dogs: menuItems.where((e) => e.classification == MenuItemClassification.dog).toList(),
        ),
        categoryMix: const {
          'Burgers': 25.8,
          'Pizza': 22.4,
          'Appetizers': 18.6,
          'Beverages': 15.2,
          'Salads': 8.7,
          'Pasta': 5.9,
          'Steaks': 2.8,
          'Seafood': 0.6,
        },
        averageItemProfitMargin: 71.2,
        menuMixAnalysis: const {
          'High-margin items': 68.5,
          'Medium-margin items': 25.2,
          'Low-margin items': 6.3,
        },
        priceElasticity: const {
          'Burgers': -1.2,
          'Pizza': -0.8,
          'Beverages': -0.3,
          'Steaks': -2.1,
        },
      ),
      foodCost: FoodCostMetricsData(
        foodCostPercentage: 29.8,
        costOfGoodsSold: 13493.59,
        foodWastePercentage: 4.2,
        inventoryTurnoverRate: 12.5,
        theoreticalVsActualFoodCost: 2.3,
        vendorCostTrends: const {
          'Proteins': [-2.5, -1.8, 0.5, 1.2, 0.8],
          'Produce': [3.2, 2.8, 1.5, -0.5, -1.2],
          'Dairy': [1.5, 2.1, 1.8, 2.5, 3.1],
          'Beverages': [-0.5, 0.2, 0.8, 0.5, 0.3],
        },
        averageRecipeCost: 8.95,
        previousPeriod: const FoodCostPeriodPrev(
          foodCostPercentage: 31.2,
          costOfGoodsSold: 13154.88,
          foodWastePercentage: 4.8,
        ),
      ),
      fixedCost: FixedCostMetricsData(
        rentPercentage: 7.5,
        utilitiesCost: 1265.50,
        insuranceCost: 890.25,
        licenseCost: 125.00,
        equipmentDepreciation: 1850.75,
        marketingSpend: 2415.80,
        marketingROI: 4.2,
        administrativeCosts: 1580.25,
        totalFixedCosts: 8127.55,
        previousPeriod: const FixedCostPeriodPrev(
          rentPercentage: 7.8,
          utilitiesCost: 1198.75,
          totalFixedCosts: 7890.25,
        ),
      ),
    );
  }
}

/// Singleton for widgets.
final RestaurantKpiBundle kRestaurantKpis = RestaurantKpiBundle.generate();
