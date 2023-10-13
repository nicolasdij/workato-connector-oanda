{
  title: "Oanda Exchange Rates API V2",

  connection: {
    fields: [
      {
        name: "api_key",
        label: "API Key",
        optional: false,
        type: :string,
        control_type: :password,
        hint: "API key provided by Oanda for your enterprise account."
      }
    ],

    authorization: {
      type: "api_key",

      apply: lambda do |connection|
        headers("Authorization": connection["api_key"])
      end
    },

    base_uri: lambda do
      "https://exchange-rates-api.oanda.com/v2/"
    end
  },

  test: lambda do |connection|
    get("currencies.json?data_set=OANDA")
  end,

  custom_action: true,
  custom_action_help: {
    learn_more_url: "https://developer.oanda.com/exchange-rates-api/#tag--v2",
    learn_more_text: "Learn more about Oanda Exchange Rates API V2",
    body: "The OANDA Exchange Rates API is an HTTP API, which provides access to OANDA's daily and real-time exchange rate data. Using the API, you may programmatically request rates which you may process and save in a format that works for your organization. For example, you can insert the rates into your own database/caching system or into files, such as a Comma Separated Value file (CSV)."
  },
  
  actions: {
    rates_spot: {
      title: "Get Rates/Spot",
      
      subtitle: "Retrieves the current exchange rate, or the rate at a specified point in time in JSON format.",
      
      description: lambda do |input|
        "Get <span class='provider'>JSON</span> quotes for base currencies"
      end,
      
      help: "The minimum update granularity of spot rates is 5 seconds. If you call this endpoint more frequently than that, you will keep getting the same rates until at least 5 seconds have elapsed (more, depending on the currencies).",
      
      input_fields: lambda do |obj_definitions|
        [
          {
            name: "base",
            label: "Base currencies",
            hint: "Base currencies for the quotes, as defined in the currencies endpoint.",
            optional: false,
            type: :array,
            of: :object,
            properties: obj_definitions["currencies"]
          },
          {
            name: "quote",
            label: "Quote currencies",
            hint: "Quote currencies for the quote, as defined in the Currencies endpoint.<br>- This parameter controls the number of quotes that are charged against your quote limit. Each quote currency returned by the API counts against your quote limit.<br>- <b>If you do not specify a 'quote' parameter, multiple quotes are returned and counted against your quote limit. You may assume that no more than about 200 quotes will be returned per API call</b>.",
            optional: true,
            sticky: true,
            type: :array,
            of: :object,
            properties: obj_definitions["currencies"]
          },
          {
            name: "date_time",
            label: "Rate datetime",
            hint: "The time zone used is the same one as set up in this Workato workspace.<br>If not specified, the real-time rate will be returned.",
            optional: true,
            sticky: true,
            type: :date_time,
            control_type: :date_time
          },
          {
            name: "interbank",
            label: "Interbank",
            hint: "Must be a number with up to two decimal digits between 0 (inclusive) and 100 (exclusive). This number represents the percentage amount used to adjust the exchange rates.",
            optional: true,
            sticky: true,
            type: :integer,
            control_type: :integer
          }
        ]
      end,
      
      output_fields: lambda do |obj_definitions|
        obj_definitions["rates_spot_response"]
      end,
      
      sample_output: lambda do
        {
          meta: {
            effective_params: {
              data_set: "OANDA",
              base_currencies: [ "USD" ],
              quote_currencies: [ "ARS" ],
              decimal_places: nil
            },
            endpoint: "spot",
            request_time: "2023-10-11T18:26:39+00:00",
            skipped_currency_pairs: []
          },
          quotes: [
            {
              base_currency: "USD",
              quote_currency: "ARS",
              bid: "350.054",
              ask: "350.073",
              midpoint: "350.064"
            }
          ]
        }
      end,
      
      execute: lambda do |connection, input|
        data_type = input[:data_type]
        base_currencies = input[:base].format_map("base=%{currency}")
        quote_currencies = input[:quote]
        date_time = input[:date_time]
        interbank = input[:interbank]

        query_string = [
          base_currencies,
          quote_currencies.present? ? quote_currencies.format_map("quote=%{currency}") : nil,
          date_time.present? ? "date_time=#{date_time.iso8601.encode_url}" : nil,
          interbank.present? ? "interbank=#{interbank}" : nil
        ].flatten.smart_join("&")

        get("rates/spot.json?#{query_string}")
      end
    },
    
    currencies: {
      title: "Get Currencies",

      subtitle: "Gets a list of valid three-character currency codes for use in the Rates endpoints.",

      description: lambda do |input|
        "Get <span class='provider'>OANDA</span> currencies"
      end,

      help: "",

      input_fields: lambda do |obj_definitions|
      end,
      
      output_fields: lambda do |obj_definitions|
        obj_definitions["currencies_response"]
      end,

      sample_output: lambda do
        {
          currencies: [
            {
              code: "ADF",
              description: "Andorran Franc"
            },
            {
              code: "ADP",
              description: "Andorran Peseta"
            },
            {
              code: "AED",
              description: "Utd. Arab Emir. Dirham"
            },
            {
              code: "AFA",
              description: "Afghanistan Old Afghani"
            },
            {
              code: "AFN",
              description: "Afghan Afghani"
            },
            {
              code: "ALL",
              description: "Albanian Lek"
            },
            {
              code: "AMD",
              description: "Armenian Dram"
            },
            {
              code: "ANG",
              description: "NL Antillian Guilder"
            },
            {
              code: "AOA",
              description: "Angolan Kwanza"
            }
          ]
        }
      end,

      execute: lambda do |connection, input|
        get("currencies.json").params(data: "OANDA")
      end
    }
  },

  triggers: {
  },

  methods: {
  },

  object_definitions: {
    currencies: {
      fields: lambda do |connection|
        [
          { 
            name: "currency",
            optional: false,
            type: :string
          }
        ]
      end
    },

    rates_spot_response: {
      fields: lambda do |connection|
        [
          { 
            name: "meta",
            type: :object,
            properties: [
              { 
                name: "effective_params",
                type: :object,
                properties: [
                  { name: "data_set", type: :string },
                  { name: "base_currencies", type: :array, of: :string },
                  { name: "quote_currencies", type: :array, of: :string },
                  { name: "decimal_places", type: :integer }
                ]
              },
              { name: "endpoint", type: :string },
              { name: "request_time", type: :timestamp, convert_input: "date_time_conversion" },
              { name: "skipped_currency_pairs", type: :object, properties: [
                { name: "base_currency", type: :string },
                { name: "quote_currency", type: :string }
              ] },
              { name: "skipped_tenors", type: :array, of: :string }
            ]
          },
          {
            name: "quotes",
            type: :array,
            of: :object,
            properties: [
              { name: "base_currency", type: :string },
              { name: "quote_currency", type: :string },
              { name: "bid", type: :number, convert_input: "float_conversion" },
              { name: "ask", type: :number, convert_input: "float_conversion" },
              { name: "midpoint", type: :number, convert_input: "float_conversion" },
            ]
          }
        ]
      end
    },
    
    currencies_response: {
      fields: lambda do |connection|
        [
          {
            name: "currencies",
            type: :array,
            of: :object,
            properties: [
              { name: "code", type: :string },
              { name: "description", type: :string }
            ]
          }
        ]
      end,
    }
  },

  pick_lists: {
  }
}
