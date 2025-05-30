defmodule <%= inspect context.web_module %>.<%= inspect Module.concat(schema.web_namespace, schema.alias) %>ControllerTest do
  use <%= inspect context.web_module %>.ConnCase

  import <%= inspect context.module %>Fixtures
  alias <%= inspect schema.module %>

  @create_attrs %{
<%= schema.params.create |> Enum.map(fn {key, val} -> "    #{key}: #{inspect(val)}" end) |> Enum.join(",\n") %>
  }
  @update_attrs %{
<%= schema.params.update |> Enum.map(fn {key, val} -> "    #{key}: #{inspect(val)}" end) |> Enum.join(",\n") %>
  }
  @invalid_attrs <%= Mix.Phoenix.to_text for {key, _} <- schema.params.create, into: %{}, do: {key, nil} %><%= if scope do %>

  setup :<%= scope.test_setup_helper %><% end %>

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all <%= schema.plural %>", %{conn: conn<%= test_context_scope %>} do
      conn = get(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create <%= schema.singular %>" do
    test "renders <%= schema.singular %> when data is valid", %{conn: conn<%= test_context_scope %>} do
      conn = post(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>", <%= schema.singular %>: @create_attrs)
      assert %{"<%= primary_key %>" => <%= primary_key %>} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= primary_key %>}")

      assert %{
               "<%= primary_key %>" => ^<%= primary_key %><%= for {key, val} <- schema.params.create |> Phoenix.json_library().encode!() |> Phoenix.json_library().decode!() do %>,
               "<%= key %>" => <%= inspect(val) %><% end %>
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn<%= test_context_scope %>} do
      conn = post(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>", <%= schema.singular %>: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "renders <%= schema.singular %> when data is valid", %{conn: conn, <%= schema.singular %>: %<%= inspect schema.alias %>{<%= primary_key %>: <%= primary_key %>} = <%= schema.singular %><%= test_context_scope %>} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= schema.singular %>}", <%= schema.singular %>: @update_attrs)
      assert %{"<%= primary_key %>" => ^<%= primary_key %>} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= primary_key %>}")

      assert %{
               "<%= primary_key %>" => ^<%= primary_key %><%= for {key, val} <- schema.params.update |> Phoenix.json_library().encode!() |> Phoenix.json_library().decode!() do %>,
               "<%= key %>" => <%= inspect(val) %><% end %>
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, <%= schema.singular %>: <%= schema.singular %><%= test_context_scope %>} do
      conn = put(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= schema.singular %>}", <%= schema.singular %>: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete <%= schema.singular %>" do
    setup [:create_<%= schema.singular %>]

    test "deletes chosen <%= schema.singular %>", %{conn: conn, <%= schema.singular %>: <%= schema.singular %><%= test_context_scope %>} do
      conn = delete(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= schema.singular %>}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"<%= schema.api_route_prefix %><%= scope_param_route_prefix %><%= schema.route_prefix %>/#{<%= schema.singular %>}")
      end
    end
  end

<%= if scope do %>  defp create_<%= schema.singular %>(%{scope: scope}) do
    <%= schema.singular %> = <%= schema.singular %>_fixture(scope)
<% else %>  defp create_<%= schema.singular %>(_) do
    <%= schema.singular %> = <%= schema.singular %>_fixture()
<% end %>
    %{<%= schema.singular %>: <%= schema.singular %>}
  end
end
