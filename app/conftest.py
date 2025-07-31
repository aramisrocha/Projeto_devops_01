import pytest
from app import app

@pytest.fixture
def cliente():
    app.testing = True
    return app.test_client()