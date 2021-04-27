defmodule ClusterExample.Repo do
  use Ecto.Repo,
    otp_app: :cluster_example,
    adapter: Ecto.Adapters.Postgres
end
