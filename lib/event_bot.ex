defmodule EventBot do
  use Marvin.Bot
  import :timer, only: [sleep: 1]

  match {:direct, ~r/event/}

  def handle_message(message, slack) do
    indicate_typing(message.channel, slack)
    case fetch_events do
      {:ok, events} ->
        events
        |> attachments
        |> send_attachment(message.channel, slack)
    end
  end

  defp fetch_events do
    HTTPoison.get("http://emberlondon.com/events.json")
    |> handle_response
    |> extract_events
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    {:ok, Poison.Parser.parse!(body)}
  end

  defp extract_events({:ok, data}) do
    {:ok, data["events"]}
  end

  defp attachments(events) do
    Enum.map(events, fn(event) ->
      %{
        color: "#e24b31",
        title: event["title"],
        title_link: event["url"]
      }
    end)
  end
end
