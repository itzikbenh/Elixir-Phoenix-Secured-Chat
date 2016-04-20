ExUnit.start

Mix.Task.run "ecto.create", ~w(-r ChatSecured.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r ChatSecured.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(ChatSecured.Repo)

