from core.config import get_settings
from openai import OpenAI
from core.prompt import *
import json


async def get_gpt_response(
    input_data: str, system_message: str, schema, function_name: str = None
):
    settings = get_settings()
    GPT_API_KEY = settings.gpt_api_key
    MODEL = "gpt-4o"

    client = OpenAI(
        api_key=GPT_API_KEY,
    )

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": input_data},
        ],
        functions=[schema],
        function_call={
            "name": function_name,
        },
        stop=None,
        temperature=0.5,
    )
    return json.loads(response.choices[0].message.function_call.arguments)
