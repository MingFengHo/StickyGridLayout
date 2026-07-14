import Foundation

/// Shared demo data used by both the UIKit (`DemoViewController`) and SwiftUI
/// (`CitiesGridView`) screens, so the two stay in sync. City names vary in
/// length on purpose, to show columns self-sizing to their content.
struct City {
    let name, country, population, timezone, currency: String
}

enum CityData {
    static let columnTitles = ["City", "Country", "Population", "Timezone", "Currency"]

    static let all: [City] = [
        City(name: "Tokyo",            country: "Japan",         population: "37,400,068", timezone: "UTC+9",  currency: "JPY"),
        City(name: "Delhi",            country: "India",         population: "32,900,000", timezone: "UTC+5:30", currency: "INR"),
        City(name: "Shanghai",         country: "China",         population: "29,200,000", timezone: "UTC+8",  currency: "CNY"),
        City(name: "São Paulo",        country: "Brazil",        population: "22,430,000", timezone: "UTC−3",  currency: "BRL"),
        City(name: "Mexico City",      country: "Mexico",        population: "22,085,000", timezone: "UTC−6",  currency: "MXN"),
        City(name: "Cairo",            country: "Egypt",         population: "21,323,000", timezone: "UTC+2",  currency: "EGP"),
        City(name: "Dhaka",            country: "Bangladesh",    population: "22,478,000", timezone: "UTC+6",  currency: "BDT"),
        City(name: "Mumbai",           country: "India",         population: "20,961,000", timezone: "UTC+5:30", currency: "INR"),
        City(name: "Beijing",          country: "China",         population: "20,896,000", timezone: "UTC+8",  currency: "CNY"),
        City(name: "Osaka",            country: "Japan",         population: "19,059,000", timezone: "UTC+9",  currency: "JPY"),
        City(name: "New York City",    country: "United States", population: "18,804,000", timezone: "UTC−5",  currency: "USD"),
        City(name: "Karachi",          country: "Pakistan",      population: "16,839,000", timezone: "UTC+5",  currency: "PKR"),
        City(name: "Buenos Aires",     country: "Argentina",     population: "15,594,000", timezone: "UTC−3",  currency: "ARS"),
        City(name: "Istanbul",         country: "Türkiye",       population: "15,415,000", timezone: "UTC+3",  currency: "TRY"),
        City(name: "Kolkata",          country: "India",         population: "15,134,000", timezone: "UTC+5:30", currency: "INR"),
        City(name: "Lagos",            country: "Nigeria",       population: "15,388,000", timezone: "UTC+1",  currency: "NGN"),
        City(name: "Manila",           country: "Philippines",   population: "14,406,000", timezone: "UTC+8",  currency: "PHP"),
        City(name: "Rio de Janeiro",   country: "Brazil",        population: "13,634,000", timezone: "UTC−3",  currency: "BRL"),
        City(name: "Johannesburg",     country: "South Africa",  population: "11,191,000", timezone: "UTC+2",  currency: "ZAR"),
        City(name: "Ho Chi Minh City", country: "Vietnam",       population: "8,993,000",  timezone: "UTC+7",  currency: "VND"),
        City(name: "Kuala Lumpur",     country: "Malaysia",      population: "8,285,000",  timezone: "UTC+8",  currency: "MYR"),
        City(name: "Saint Petersburg", country: "Russia",        population: "5,468,000",  timezone: "UTC+3",  currency: "RUB"),
        City(name: "San Francisco",    country: "United States", population: "3,300,000",  timezone: "UTC−8",  currency: "USD"),
        City(name: "Zürich",           country: "Switzerland",   population: "1,435,000",  timezone: "UTC+1",  currency: "CHF"),
        City(name: "Copenhagen",       country: "Denmark",       population: "1,346,000",  timezone: "UTC+1",  currency: "DKK"),
        City(name: "Ulaanbaatar",      country: "Mongolia",      population: "1,645,000",  timezone: "UTC+8",  currency: "MNT"),
        City(name: "Reykjavík",        country: "Iceland",       population: "131,136",    timezone: "UTC+0",  currency: "ISK"),
        City(name: "Wellington",       country: "New Zealand",   population: "418,500",    timezone: "UTC+12", currency: "NZD"),
    ]
}
