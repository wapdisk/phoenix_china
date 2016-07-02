defmodule PhoenixChina.SessionController do
  use PhoenixChina.Web, :controller

  alias PhoenixChina.User

  def new(conn, _params) do
    changeset = User.changeset(:signin, %User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(:signin, %User{}, user_params)
    |> validate_email
    |> validate_password

    case changeset.valid? do
      true ->
        user = (from User, where: [email: ^user_params["email"]]) |> first |> Repo.one
        conn
        |> put_session(:user_id, user.id)
        |> put_session(:current_user, user)
        |> put_flash(:info, "登陆成功！")
        |> redirect(to: page_path(conn, :index))
      false ->
        changeset = %{changeset | action: :signin}
        render(conn, "new.html", changeset: changeset)
    end
  end

  defp validate_email(changeset) do
    user = (from User, where: [email: ^changeset.changes.email]) |> first |> Repo.one
    if !changeset.errors[:email] && !user do
      changeset = changeset
      |> Ecto.Changeset.add_error(:email, "用户不存在")
    end
    changeset
  end

  defp validate_password(changeset) do
    user = (from User, where: [email: ^changeset.changes.email]) |> first |> Repo.one
    if !changeset.errors[:email]
    && !changeset.errors[:password]
    && !User.check_password(changeset.changes.password, user.password_hash) do
      changeset = changeset
      |> Ecto.Changeset.add_error(:password, "密码错误，请重新输入")
    end
    changeset
  end

  def delete(conn, _params) do
    conn
    |> put_session(:user_id, nil)
    |> put_session(:current_user, nil)
    |> put_flash(:info, "已退出登陆")
    |> redirect(to: page_path(conn, :index))
  end
end