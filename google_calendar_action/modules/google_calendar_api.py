"""This module contains the GoogleCalendarAPI class which is used to interact with the Google Calendar API."""

import logging
import uuid
from datetime import datetime, timedelta, timezone

from google.oauth2 import service_account
from googleapiclient.discovery import Resource, build
from googleapiclient.errors import HttpError


class GoogleCalendarAPI:
    """Class for interacting with the Google Calendar API."""

    logger = logging.getLogger(__name__)

    def __init__(
        self,
        info_type: str,
        scopes: list,
        calendar_id: str,
        project_id: str,
        private_key_id: str,
        private_key: str,
        client_email: str,
        client_id: str,
        auth_uri: str,
        token_uri: str,
        auth_provider_x509_cert_url: str,
        client_x509_cert_url: str,
        universe_domain: str,
        google_api_client_name: str,
        google_api_client_version: str,
        resource_id: str,
    ) -> None:
        """
        Initializes the GoogleSheetAPI object with credentials.

        :param credentials: Dictionary containing Google API credentials.
        """

        self.credentials = {
            "type": info_type,
            "project_id": project_id,
            "private_key_id": private_key_id,
            "private_key": private_key,
            "client_email": client_email,
            "client_id": client_id,
            "auth_uri": auth_uri,
            "token_uri": token_uri,
            "auth_provider_x509_cert_url": auth_provider_x509_cert_url,
            "client_x509_cert_url": client_x509_cert_url,
            "universe_domain": universe_domain,
        }

        self.scopes = scopes
        self.calendar_id = calendar_id
        self.google_api_client_name = google_api_client_name
        self.google_api_client_version = google_api_client_version
        self.resource_id = resource_id

    def build_services(self) -> Resource:
        """Builds the Google Calendar API service using the provided credentials."""
        credentials = service_account.Credentials.from_service_account_info(
            self.credentials, scopes=self.scopes
        )
        return build(
            self.google_api_client_name,
            self.google_api_client_version,
            credentials=credentials,
        )

    def create_event(self, event_info: dict) -> dict:
        """Creates an event in the Google Calendar."""

        try:
            service = self.build_services()
            event = (
                service.events()
                .insert(calendarId=self.calendar_id, body=event_info)
                .execute()
            )
            return event
        except Exception as e:
            self.logger.error(f"Google Calendar API: Error creating event: {e}")
            return {}

    def list_events(
        self,
        max_results: int = 2500,
        single_events: bool = True,
        order_by: str = "startTime",
    ) -> list:
        """Lists events from the Google Calendar."""

        try:

            service = self.build_services()
            now = datetime.now(timezone.utc).isoformat()
            events_result = (
                service.events()
                .list(
                    calendarId=self.calendar_id,
                    timeMin=now,
                    maxResults=max_results,
                    singleEvents=single_events,
                    orderBy=order_by,
                )
                .execute()
            )
            events = events_result.get("items", [])
            return events
        except Exception as e:
            self.logger.error(f"Google Calendar API: Error listing events: {e}")
            return []

    def get_event(self, event_id: str) -> dict:
        """Gets an event from the Google Calendar."""
        try:
            service = self.build_services()
            event = (
                service.events()
                .get(calendarId=self.calendar_id, eventId=event_id)
                .execute()
            )
            return event
        except Exception as e:
            self.logger.error(
                f"Google Calendar API: Error getting event {event_id}: {e}"
            )
            return {}

    def delete_event(self, event_id: str) -> bool:
        """Deletes an event from the Google Calendar."""

        try:
            service = self.build_services()
            service.events().delete(
                calendarId=self.calendar_id, eventId=event_id
            ).execute()
            return True
        except Exception as e:
            self.logger.error(
                f"Google Calendar API: Error deleting event {event_id}: {e}"
            )
            return False

    def update_event(self, event_id: str, updated_event_info: dict) -> dict:
        """Updates an event in the Google Calendar."""

        try:
            service = self.build_services()
            updated_event = (
                service.events()
                .update(
                    calendarId=self.calendar_id,
                    eventId=event_id,
                    body=updated_event_info,
                )
                .execute()
            )
            return updated_event
        except Exception as e:
            self.logger.error(
                f"Google Calendar API: Error updating event {event_id}: {e}"
            )
            return {}

    def update_webhook(self, webhook_url: str, days_before: int = 1) -> dict:
        """
        Updates the webhook for a Google Calendar.

        Parameters:
        - webhook_url: The URL to receive notifications.
        - calendar_id: The ID of the calendar to be watched.
        - channel_id: A unique ID for the channel(agent_id).

        Returns:
        dict: A dictionary containing details of the channel, such as kind, id, resourceId, resourceUri, and expiration.
        """

        service = self.build_services()
        channel_id = uuid.uuid4().hex
        channel = {"id": channel_id, "type": "web_hook", "address": webhook_url}

        try:
            response = (
                service.events()
                .watch(
                    calendarId=self.calendar_id,
                    body=channel,
                )
                .execute()
            )

            # get x days before expiration
            timestamp_seconds = int(response["expiration"]) / 1000
            expiration_datetime = datetime.fromtimestamp(
                timestamp_seconds, tz=timezone.utc
            )
            new_expiration_datetime = expiration_datetime - timedelta(days=days_before)
            expiration_timestamp = int(new_expiration_datetime.timestamp())
            response["before_expiration"] = expiration_timestamp

            return response
        except HttpError as error:
            self.logger.error(f"Google Calendar API: Error {error}")
            return {}

    def validate_request(self, request: dict) -> bool:
        """
        Validates that the request object matches the expected resource_id.

        Args:
        request: dict, A dictionary containing the request headers.

        Returns:
        bool: True if the request object matches the expected resource_id, False otherwise.
        """
        try:
            # Ensure headers exist before accessing
            id = request.get("x-goog-resource-id")

            if not id:
                return False

            return id == self.resource_id

        except Exception as e:
            self.logger.error(f"Google Calendar API: Invalid request object: {e}")
            return False
