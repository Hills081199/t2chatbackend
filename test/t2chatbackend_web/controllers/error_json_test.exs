defmodule T2chatbackendWeb.ErrorJSONTest do
  use T2chatbackendWeb.ConnCase, async: true

  test "renders 404" do
    assert T2chatbackendWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert T2chatbackendWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
