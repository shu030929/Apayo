from pymongo import MongoClient
from api.schemas.disease_prediction_session import DiseasePredictionSession
from typing import Dict, List
from datetime import datetime
from core.config import get_settings

settings = get_settings()


class SessionManager:
    _sessions_cache = {}
    _db = None

    @staticmethod
    def get_db():
        if SessionManager._db is None:
            client = MongoClient(settings.mongo_uri)
            SessionManager._db = client["Apayo"]
        return SessionManager._db

    @staticmethod
    def create_session(user_id: str) -> DiseasePredictionSession:
        """Create a new session and save it to MongoDB."""
        db = SessionManager.get_db()

        new_session = DiseasePredictionSession(user_id=user_id)
        session_data = new_session.model_dump()
        db.disease_prediction_sessions.insert_one(session_data)
        # Cache the session locally
        SessionManager._sessions_cache[new_session.session_id] = new_session
        return new_session

    @staticmethod
    def get_session_by_id(session_id: str) -> DiseasePredictionSession:
        """Retrieve a session from the local cache or MongoDB."""
        db = SessionManager.get_db()

        if session_id in SessionManager._sessions_cache:
            return SessionManager._sessions_cache[session_id]

        session_data = db.disease_prediction_sessions.find_one(
            {"session_id": session_id}
        )
        if session_data:
            session = DiseasePredictionSession(**session_data)
            SessionManager._sessions_cache[session_id] = session
            return session
        raise ValueError("Session not found")

    @staticmethod
    def get_session_by_user(user_id: str) -> List[DiseasePredictionSession]:
        """Retrieve a session from the local cache or MongoDB."""
        db = SessionManager.get_db()

        session_data = list(db.disease_prediction_sessions.find({"user_id": user_id}))
        sessions = []
        if session_data:
            for data in session_data:
                session = DiseasePredictionSession(**data)
                sessions.append(session)
            return sessions
        raise ValueError("Session not found")

    @staticmethod
    def update_session(session_id: str, updates: Dict[str, any]):
        """Update an existing session both locally and in MongoDB."""
        db = SessionManager.get_db()
        session = SessionManager.get_session_by_id(session_id)
        if not session:
            raise ValueError("Session not found")

        # Update session with new data provided in updates dictionary
        for key, value in updates.items():
            setattr(session, key, value)

        session.updated_at = datetime.now()

        # Convert the entire session to a dictionary format suitable for MongoDB
        updated_session_data = session.model_dump()
        # Update the local cache
        SessionManager._sessions_cache[session_id] = session

        # Update MongoDB
        db.disease_prediction_sessions.update_one(
            {"session_id": session_id}, {"$set": updated_session_data}
        )
