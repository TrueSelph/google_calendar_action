"""This module render the streamlit app for the google calendar action."""

import streamlit as st
from jvclient.lib.utils import call_api
from jvclient.lib.widgets import app_controls, app_header, app_update_action
from streamlit_router import StreamlitRouter


def render(router: StreamlitRouter, agent_id: str, action_id: str, info: dict) -> None:
    """Render the streamlit app for the google calendar action.

    :param router: StreamlitRouter instance
    :param agent_id: agent id
    :param action_id: action id
    :param info: action info
    """

    # add app header controls
    (model_key, module_root) = app_header(agent_id, action_id, info)

    with st.expander("Google Calendar Configuration", expanded=False):
        # Add main app controls
        app_controls(agent_id, action_id)
        # Add update button to apply changes
        app_update_action(agent_id, action_id)

    # Add Register Webhook section
    with st.expander("Register Webhook", expanded=True):
        st.markdown("### Webhook Registration")
        st.markdown(
            "Click the button below to register the webhook."
            "This enables your agent to communicate with Google Calendar."
        )

        # Register Webhook button
        if st.button("Register Webhook", key=f"{model_key}_btn_register_webhook"):
            result = call_api(
                endpoint="action/walker/google_calendar_action/register_google_calendar_webhook",
                json_data={"agent_id": agent_id},
            )
            if result:
                st.success("Webhook registered successfully!")
            else:
                st.error("Failed to register webhook. Please try again.")
