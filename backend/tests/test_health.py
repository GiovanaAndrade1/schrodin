from unittest.mock import patch

import pytest
from django.db import OperationalError
from django.test import Client


@pytest.mark.django_db
def test_health_returns_ok_when_database_responds(client: Client) -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": "ok"}


def test_health_returns_503_when_database_is_down(client: Client) -> None:
    with patch("apps.core.views.connection.cursor", side_effect=OperationalError("down")):
        response = client.get("/health")
    assert response.status_code == 503
    assert response.json() == {"status": "error", "database": "unavailable"}
