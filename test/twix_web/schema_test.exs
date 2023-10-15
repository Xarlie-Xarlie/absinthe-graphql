defmodule TwixWeb.SchemaTest do
  alias Twix.Users.User
  use TwixWeb.ConnCase, async: true

  describe "users query" do
    test "query user info", %{conn: conn} do
      user_params = %{nickname: "josé", age: 33, email: "jose@mail.com"}

      {:ok, user} = Twix.create_user(user_params)

      query = """
      {
        user(id: #{user.id}){
          nickname
          email
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{"user" => %{"nickname" => "josé", "email" => "jose@mail.com"}}
             }
    end

    test "when there is an error, returns the error", %{conn: conn} do
      query = """
      {
        user(id: 1){
          nickname
          email
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{"user" => nil},
               "errors" => [
                 %{
                   "locations" => [%{"column" => 3, "line" => 2}],
                   "message" => "not_found",
                   "path" => ["user"]
                 }
               ]
             }
    end
  end

  describe "users mutation" do
    test "when all params are valid, creates the user", %{conn: conn} do
      query = """
      mutation{
        createUser(input: {
          age: 23, 
          email: "charlie@email.com",
          nickname: "charlie"
        }){
          nickname
          email
          age
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{
                 "createUser" => %{
                   "nickname" => "charlie",
                   "email" => "charlie@email.com",
                   "age" => 23
                 }
               }
             }
    end

    test "when params contains error, returns the error", %{conn: conn} do
      query = """
      mutation{
        createUser(input: {
          email: "charlie@email.com",
          nickname: "charlie"
        }){
          nickname
          email
          age
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "errors" => [
                 %{
                   "locations" => [%{"column" => 14, "line" => 2}],
                   "message" =>
                     "Argument \"input\" has invalid value {email: \"charlie@email.com\", nickname: \"charlie\"}.\nIn field \"age\": Expected type \"Int!\", found null."
                 }
               ]
             }
    end

    test "when params contains validation errors, returns the error", %{conn: conn} do
      query = """
      mutation{
        createUser(input: {
          age: 17
          email: "charlie@email.com",
          nickname: "charlie"
        }){
          nickname
          email
          age
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "errors" => [
                 %{
                   "locations" => [%{"column" => 3, "line" => 2}],
                   "message" => "age must be greater than or equal to 18",
                   "path" => ["createUser"]
                 }
               ],
               "data" => %{"createUser" => nil}
             }
    end

    test "update the user", %{conn: conn} do
      user_params = %{nickname: "josé", age: 33, email: "jose@mail.com"}

      {:ok, user} = Twix.create_user(user_params)

      query = """
      mutation{
        updateUser(input: {
          id: #{user.id}
          age: 23
          email: "charlie@email.com",
          nickname: "charlie"
        }){
          nickname
          email
          age
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(200)

      assert response == %{
               "data" => %{
                 "updateUser" => %{
                   "age" => 23,
                   "email" => "charlie@email.com",
                   "nickname" => "charlie"
                 }
               }
             }

      assert %User{age: 23, email: "charlie@email.com", nickname: "charlie"} =
               Twix.Repo.one(User, id: user.id)
    end
  end

  describe "subscriptions" do
    test "new follow", %{socket: socket} do
      user_params = %{nickname: "jose1", age: 22, email: "jose1@bananinha.com"}

      {:ok, user1} = Twix.create_user(user_params)

      user_params = %{nickname: "jose2", age: 23, email: "jose2@bananinha.com"}

      {:ok, user2} = Twix.create_user(user_params)

      mutation = """
      mutation{
        addFollower(input: {userId: #{user1.id}, followerId: #{user2.id}}){
          followerId
          followingId
        }
      }
      """

      subscription = """
      subscription{
        newFollow{
          followerId
          followingId
        }
      }
      """

      # Setup da subscription
      socket_ref = push_doc(socket, subscription)
      assert_reply(socket_ref, :ok, %{subscriptionId: subscription_id})

      socket_ref = push_doc(socket, mutation)
      assert_reply(socket_ref, :ok, mutation_response)

      assert %{
               data: %{
                 "addFollower" => %{"followerId" => "#{user2.id}", "followingId" => "#{user1.id}"}
               }
             } ==
               mutation_response

      assert_push("subscription:data", subscription_response)

      assert %{
               result: %{
                 data: %{
                   "newFollow" => %{"followerId" => "#{user2.id}", "followingId" => "#{user1.id}"}
                 }
               },
               subscriptionId: subscription_id
             } == subscription_response
    end
  end
end
