from pydantic import BaseModel
from typing import Dict
from uuid import uuid4


def generate_uuid() -> str:
    return str(uuid4())


class UserQuestionResponse(BaseModel):
    session_id: str
    responses: Dict[str, str]  # 질문ID:응답


class PredictedDisease(BaseModel):
    Disease: str
    recommended_department: str
    description: str