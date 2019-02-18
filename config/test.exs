use Mix.Config

config :btrz_ex_api_client, :http_client, BtrzExApiClient.HTTPClientMock

config :btrz_ex_api_client, :services,
  accounts: "http://localhost:3050/accounts/",
  webhooks: "http://localhost:4000/webhooks/",
  loyalty: "http://localhost:4010/loyalty/",
  seatmaps: "http://localhost:4020/seatmaps/",
  inventory: "http://localhost:3010/inventory/",
  sales: "http://localhost:3020/sales/",
  reports: "http://localhost:3030/reports/",
  uploads: "http://localhost:3040/uploads/",
  notifications: "http://localhost:3060/notifications/",
  operations: "http://localhost:3070/operations/"

config :btrz_ex_api_client, :internal_token,
  main_secret: "Hf45fFc89SJ204kowbPIQ3Ui2Oxn2a8OWlEi6RTkuOd0jHvZiZh0EWwOxSVul5eS",
  secondary_secret: "0IAWv5Qe1Mvp5x5xtv1rpxFsO38ylCSXV6uQktSIGoQob79ELkjbNQUWIxOKoaU4"
