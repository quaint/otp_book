defmodule MasteryPersistence do
  import Ecto.Query, only: [from: 2]
  alias MasteryPersistence.{Response, Repo}

  def record_response(response, in_transaction \\ fn _response -> :ok end) do
    {:ok, result} =
      Repo.transaction(fn ->
        %{
          quiz_title: to_string(response.quiz_title),
          template_name: to_string(response.template_name),
          to: to_string(response.to),
          email: to_string(response.email),
          answer: to_string(response.answer),
          correct: to_string(response.correct),
          inserted_at: to_string(response.timestamp),
          updated_at: to_string(response.timestamp)
        }
        |> Response.record_changeset()
        |> Repo.insert!()

        in_transaction.(response)
      end)

    result
  end

  def report(quiz_title) do
    quiz_title = to_string(quiz_title)

    from(
      r in Response,
      select: {r.email, count(r.id)},
      where: r.quiz_title == ^quiz_title,
      group_by: [r.quiz_title, r.email]
    )
    |> Repo.all()
    |> Enum.into(Map.new())
  end
end
