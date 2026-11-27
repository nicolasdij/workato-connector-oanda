# Workato connector for the OANDA Exchange Rates API

A custom [Workato](https://www.workato.com) connector for the [OANDA Exchange Rates API (v2)](https://developer.oanda.com/exchange-rates-api/#tag--v2).

Use it in Workato recipes that need up-to-date exchange rates and currency conversions, for example in finance automations.

The connector is available in the Workato Community Library as **Oanda Exchange Rates API V2**.

## Features

| Action | What it does |
|---|---|
| **Get Currencies** | Returns the list of valid three-letter currency codes, with a description for each code. |
| **Get Rates/Spot** | Returns the current exchange rate, or the rate at a given date and time, for one or more currency pairs. |
| **Custom action** | Calls any other endpoint of the OANDA Exchange Rates API v2. |

The connector has no triggers.

## Connection

You need an API key from an OANDA enterprise account.

1. In Workato, add a new connection and select this connector.
2. Enter your **API Key**.
3. Workato tests the connection with a call to the `currencies` endpoint.

The connector sends the key in the `Authorization` header. The base URL is `https://exchange-rates-api.oanda.com/v2/`.

## Actions

### Get Currencies

- **Input:** none.
- **Output:** a list of currencies, each with `code` and `description`.

Use the codes from this action as input for **Get Rates/Spot**.

### Get Rates/Spot

**Input**

| Field | Required | Description |
|---|---|---|
| Base currencies | Yes | One or more base currencies, for example `USD` and `GBP`. |
| Quote currencies | No | One or more quote currencies, for example `ARS`. If empty, the API returns many quotes (up to about 200), and each quote counts against your quote limit. |
| Rate datetime | No | The date and time of the rate. Workato uses the time zone of your workspace. If empty, you get the real-time rate. |
| Interbank | No | A percentage (from 0 to less than 100) to adjust the rates. |

**Output**

- `meta`: the parameters that the API used, the endpoint, the request time and any skipped currency pairs.
- `quotes`: one item for each currency pair, with `base_currency`, `quote_currency`, `bid`, `ask` and `midpoint`.

**Example output**

```json
{
  "quotes": [
    {
      "base_currency": "USD",
      "quote_currency": "ARS",
      "bid": "350.054",
      "ask": "350.073",
      "midpoint": "350.064"
    }
  ]
}
```

**Notes**

- Spot rates change at most every 5 seconds. If you call the action more often, you get the same rates.
- Set **Quote currencies** to control how many quotes count against your OANDA quote limit.
