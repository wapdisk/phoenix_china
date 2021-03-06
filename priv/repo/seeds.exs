# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhoenixChina.Repo.insert!(%PhoenixChina.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias PhoenixChina.{Repo, PostLabel, User, ModelOperator}

labels = ["公告", "问题", "经验", "分享", "灌水", "招聘"]

Enum.map(Enum.with_index(labels), fn {name, index} ->
  label = PostLabel |> Repo.get_by(content: name)
  
  cond do
    is_nil(label) -> Repo.insert(%PostLabel{content: name, order: index})
    label.order != index and is_nil(label.is_hide) ->
      PostLabel |> ModelOperator.set(label, :order, index)
      PostLabel |> ModelOperator.set(label, :is_hide, false)
    label.order != index -> PostLabel |> ModelOperator.set(label, :order, index)
    is_nil(label.is_hide) -> PostLabel |> ModelOperator.set(label, :is_hide, false)
    true -> ""
  end
end)

Enum.map(Repo.all(User), fn user ->
  if is_nil(user.nickname) do
    User |> ModelOperator.set(user, :nickname, user.username)
  end
end)
