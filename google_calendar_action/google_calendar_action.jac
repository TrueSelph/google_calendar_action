import:py os;
import:py pytz;
import:py logging;
import:py traceback;
import:py from typing { Union }
import:py from logging { Logger }
import:py from datetime { datetime }
import:py from jvserve.lib.agent_interface { AgentInterface }
import:py from .modules.google_calendar_api {GoogleCalendarAPI}
import:jac from jivas.agent.action.action { Action }

node GoogleCalendarAction :Action: {

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


    can on_enable() {
        # check if enabled
        if(self.enabled) {
            # register polls webhook
            self.enabled = self.on_register();
        }
    }

    can on_register() -> bool {
        if (not self.base_url) {
            # default to jivas base url in environment
            self.base_url = os.environ.get('JIVAS_BASE_URL');
        }

        if(self.enabled) {
            # setup procedure for webhook registration on google calendar api
            agent_id = self.get_agent().id;
            module_root = self.get_module_root();
            # generate webhook key
            webhook_key = AgentInterface.encrypt_webhook_key(agent_id=agent_id, module_root=module_root, walker="google_calendar_interact");

            credentials = self.get_credentials();

            if(self.enabled and self.base_url and webhook_key and credentials) {
                # complete the full webhook url
                self.webhook_url = f'{self.base_url}/webhook/{webhook_key}';

                result = GoogleCalendarAPI.update_webhook(credentials, self.webhook_url, self.calendar_id, 2);

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
    }

    can validate_request(headers:dict) -> bool {
        current_timestamp = int((datetime.now(pytz.timezone(self.timezone))).timestamp());

        valid_request = GoogleCalendarAPI.validate_request(headers, self.resource_id);
        if(valid_request) {
            self.last_modified_timestamp = int(current_timestamp);
        }

        if(current_timestamp > self.expiration and self.enabled){
            self.register_google_calendar_webhook();
        }

        return valid_request;
    }


    can get_credentials() -> dict {

        if( not
            (self.scopes and
            self.calendar_id and
            self.info_type and
            self.project_id and
            self.private_key_id and
            self.private_key and
            self.client_email and
            self.client_id and
            self.auth_uri and
            self.token_uri and
            self.auth_provider_x509_cert_url and
            self.client_x509_cert_url and
            self.universe_domain)
        ) {
            return {};
        }

        credentials = {
            "credentials": {
                "type": self.info_type,
                "project_id": self.project_id,
                "private_key_id": self.private_key_id,
                "private_key": self.private_key,
                "client_email": self.client_email,
                "client_id": self.client_id,
                "auth_uri": self.auth_uri,
                "token_uri": self.token_uri,
                "auth_provider_x509_cert_url": self.auth_provider_x509_cert_url,
                "client_x509_cert_url": self.client_x509_cert_url,
                "universe_domain": self.universe_domain
            },
            "scopes": self.scopes,
            "calendar_id": self.calendar_id
        };

        return credentials;
    }


    can create_event(event_info:dict) -> dict {
        credentials = self.get_credentials();
        event = GoogleCalendarAPI.create_event(credentials, event_info);
        return event;
    }


    can list_events(max_results:int = 2500, single_events:bool = True, order_by:str = "startTime") -> list {
        credentials = self.get_credentials();
        events = GoogleCalendarAPI.list_events(credentials, max_results=max_results, single_events=single_events, order_by=order_by);
        return events;
    }


    can get_event(event_id:str) -> dict {
        credentials = self.get_credentials();
        event = GoogleCalendarAPI.get_event(credentials, event_id);
        return event;
    }


    can update_event(event_id:str, event_info:dict) -> dict {
        credentials = self.get_credentials();
        event = GoogleCalendarAPI.update_event(credentials, event_id, event_info);
        return event;
    }


    can delete_event(event_info:dict) -> bool {
        credentials = self.get_credentials();
        result = GoogleCalendarAPI.delete_event(credentials, event_info);
        return result;
    }

    can healthcheck() -> Union[bool, dict] {

        if not self.get_credentials() {
            return {
                "status": False,
                "message": "Missing API credentials. Check configuration.",
                "severity": "error"
            };
        }

        return True;
    }

}


