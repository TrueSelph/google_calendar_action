import logging;
import from logging { Logger }
import from jivas.agent.core.agent { Agent }
import from jivas.agent.action.action_webhook_walker { action_webhook_walker }


walker google_calendar_interact(action_webhook_walker) {
    # called via a webhook whenever there are verification requests or inbound messages
    # when activated, it will trigger the facebook interact action to communicate

    # set up logger
    static has logger:Logger = logging.getLogger(__name__);

    has headers:dict = {};
    # main param for incoming webhook data
    has params:dict = {};
    # main param for outgoing webhook data
    has response:dict = {};

    can on_agent with Agent entry {

        # when the webhook triggered update last_modified_timestamp in GoogleCalendarAction
        if( action_node:=(here.get_actions().get(action_label='GoogleCalendarAction')) ) {
            action_node.validate_request(self.headers, action_node);
        }
    }
}