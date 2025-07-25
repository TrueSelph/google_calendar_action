import os;
import pytz;
import logging;
import traceback;
import from typing { Union }
import from logging { Logger }
import from datetime { datetime }
import from jvserve.lib.agent_interface { encrypt_webhook_key_exec }
import from .modules.google_calendar_api {GoogleCalendarAPI}
import from jivas.agent.action.action { Action }

node GoogleCalendarAction(Action) {

    has timezone:str = "";
    has scopes:list = ["https://www.googleapis.com/auth/calendar"];
    has calendar_id:str = "";
    has base_url:str = "";
    has webhook_url:str = "";
    has resource_id:str = "";
    has expiration:int = 0;
    has last_modified_timestamp:int = 0;
    has info_type:str = "service_account";
    has project_id:str = "";
    has private_key_id:str = "";
    has private_key:str = "";
    has client_email:str = "";
    has client_id:str = "";
    has auth_uri:str = "https://accounts.google.com/o/oauth2/auth";
    has token_uri:str = "https://oauth2.googleapis.com/token";
    has auth_provider_x509_cert_url:str = "https://www.googleapis.com/oauth2/v1/certs";
    has client_x509_cert_url:str = "";
    has universe_domain:str = "googleapis.com";
    has google_api_client_name:str = "calendar";
    has google_api_client_version:str = "v3";


    def on_enable() {
        self.enabled = self.on_register();
    }

    def on_register() -> bool {
        if (not self.base_url) {
            # default to jivas base url in environment
            self.base_url = os.environ.get('JIVAS_BASE_URL');
        }

        self.register_session();
    }

    def healthcheck() -> Union[bool, dict] {
        try {
            events = self.api().list_events(max_results = 1, single_events=False);
            if "error" in events {
                return {
                    "status": False,
                    "message": f"{events['error']}",
                    "severity": "error"
                };
            }

            return True;

        }except Exception as e{
            self.logger.error(f"An exception occurred in {self.label}:\n{traceback.format_exc()}\n");
            return False;
        }
    }

    # --------------- GoogleCalendarAPI ----------------

    def api() -> GoogleCalendarAPI {
        # load the api instance

        return GoogleCalendarAPI(
            info_type=self.info_type,
            scopes=self.scopes,
            calendar_id=self.calendar_id,
            project_id=self.project_id,
            private_key_id=self.private_key_id,
            private_key=self.private_key,
            client_email=self.client_email,
            client_id=self.client_id,
            auth_uri=self.auth_uri,
            token_uri=self.token_uri,
            auth_provider_x509_cert_url=self.auth_provider_x509_cert_url,
            client_x509_cert_url=self.client_x509_cert_url,
            universe_domain=self.universe_domain,
            google_api_client_name=self.google_api_client_name,
            google_api_client_version=self.google_api_client_version,
            resource_id=self.resource_id
        );

    }

    def register_session() -> dict {
        # setup procedure for webhook registration on api

        result = {};

        agent_id = self.get_agent().id;
        module_root = self.get_module_root();
        # generate webhook key
        webhook_key = encrypt_webhook_key_exec(agent_id=agent_id, module_root=module_root, walker="google_calendar_interact");

        if(not self.enabled) {
            return False;
        }


        if(self.base_url and webhook_key) {
            # complete the full webhook url
            self.webhook_url = f'{self.base_url}/action/webhook/{webhook_key}';

            result = self.api().update_webhook(self.webhook_url, 2);

            if not result {
                return False;
            }

            self.resource_id = result.get("resourceId");
            self.expiration = int(result.get("before_expiration"));

            return True;
        } else {
            self.logger.error('unable to generate webhook url for Google Calendar, missing required parameters');
        }
        return False;
    }

    def validate_request(headers:dict, action_node:Action) -> bool {
        current_timestamp = int((datetime.now(pytz.timezone(action_node.timezone))).timestamp());

        valid_request = action_node.api().validate_request(headers);
        if(valid_request) {
            action_node.last_modified_timestamp = int(current_timestamp);
        }

        if(current_timestamp > action_node.expiration and action_node.enabled){
            action_node.on_register();
        }

        return valid_request;
    }

}


