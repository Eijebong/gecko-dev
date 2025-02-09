# Metrics we collect

We adhere to [Activity Stream's data collection policy](https://github.com/mozilla/activity-stream/blob/master/docs/v2-system-addon/data_events.md). Data about your specific browsing behavior or the sites you visit is **never transmitted to any Mozilla server**.  At any time, it is easy to **turn off** this data collection by [opting out of Firefox telemetry](https://support.mozilla.org/kb/share-telemetry-data-mozilla-help-improve-firefox).

## User event pings

The Onboarding system add-on sends 2 types of pings(HTTPS POST) to the backend [Onyx server](https://github.com/mozilla/onyx) :
- a `session` ping that describes the ending of an Onboarding session (a new tab is closed or refreshed, an overlay is closed, a notification bar is closed), and
- an `event` ping that records specific data about individual user interactions while interacting with Onboarding

For reference, Onyx is a Mozilla owned service to serve tiles for the current newtab in Firefox. It also receives all the telemetry from the about:newtab and about:home page as well as Activity Stream. It's operated and monitored by the Cloud Services team.

# Example Onboarding `session` Log

```js
{
  // These fields are sent from the client
  "addon_version": "1.0.0",
  "category": ["overlay-interactions"|"notification-interactions"],
  "client_id": "374dc4d8-0cb2-4ac5-a3cf-c5a9bc3c602e",
  "locale": "en-US",
  "event": ["onboarding_session" | "overlay_session" | "notification_session"],
  "page": ["about:newtab" | "about:home"],
  "session_begin": 1505440017018,
  "session_end": 1505440021992,
  "session_id": "{12dasd-213asda-213dkakj}",
  "tour_source": ["default" | "watermark"],
  "tour_id": ["onboarding-tour-private-browsing" | "onboarding-tour-addons"|...], // tour ids defined in 'onboardingTourset'

  // These fields are generated on the server
  "date": "2016-03-07",
  "ip": "10.192.171.13",
  "ua": "python-requests/2.9.1",
  "receive_at": 1457396660000
}
```

# Example Onboarding `event` Log

```js
{
  "addon_version": "1.0.0",
  "category": ["overlay-interactions"|"notification-interactions"],
  "client_id": "374dc4d8-0cb2-4ac5-a3cf-c5a9bc3c602e",
  "event": ["notification-cta-click" | "overlay-cta-click" | "overlay-nav-click" | "overlay-skip-tour"],
  "impression": [0-8],
  "locale": "en-US",
  "page": ["about:newtab" | "about:home"],
  "session_id": "{12dasd-213asda-213dkakj}",
  "tour_id": ["onboarding-tour-private-browsing" | "onboarding-tour-addons"|...], // tour ids defined in 'onboardingTourset'

  // These fields are generated on the server
  "ip": "10.192.171.13",
  "ua": "python-requests/2.9.1",
  "receive_at": 1457396660000,
  "date": "2016-03-07",
}
```


| KEY | DESCRIPTION | &nbsp; |
|-----|-------------|:-----:|
| `addon_version` | [Required] The version of the Onboarding addon. | :one:
| `category` | [Required] Either ("overlay-interactions", "notification-interactions") to identify which kind of the interaction | :one:
| `client_id` | [Required] An identifier generated by [ClientID](https://github.com/mozilla/gecko-dev/blob/master/toolkit/modules/ClientID.jsm) module to provide an identifier for this device. Auto append by `ping-centre` module | :one:
| `event` | [Required] The type of event. allowed event strings are defined in the below section | :one:
| `impression` | [Optional] An integer to record how many times the current notification tour is shown to the user. Each Notification tour can show not more than 8 times. We put `-1` when this field is not relevant to this event | :one:
| `ip` | [Auto populated by Onyx] The IP address of the client. Onyx does use (with the permission) the IP address to infer user's geo information so that it could prepare the corresponding tiles for the country she lives in. However, Ping-centre will NOT store IP address in the database, where only authorized Mozilla employees can access the telemetry data, and all the raw logs are being strictly managed by the Ops team and will expire according to the Mozilla's data retention policy.| :two:
| `locale` | The browser chrome's language (eg. en-US). | :two:
| `page` | [Required] One of ["about:newtab", "about:home"]| :one:
| `session_begin` | Timestamp in (integer) milliseconds when onboarding/overlay/notification becoming visible. | :one:
| `session_end` | Timestamp in (integer) milliseconds when onboarding/overlay/notification losing focus. | :one:
| `session_id` | [Required] The unique identifier generated by `gUUIDGenerator` service to identify the specific user session when onboarding is inited/when overlay is opened/when notification is shown. | :one:
| `tour_source` | Either ("default", "watermark") indicates the overlay is opened while in the default or the watermark state. Open from the notification bar is counted via 'notification-cta-click event'. | :two:
| `tour_id` | id of the current tour. The number of open from notification can be retrieved via 'notification-cta-click event'. We put ` ` when this field is not relevant to this event | :two:
| `ua` | [Auto populated by Onyx] The user agent string. | :two:
| `ver` | [Auto populated by Onyx] The version of the Onyx API the ping was sent to. | :one:

**Where:**

:one: Firefox data
:two: HTTP protocol data

## Events

Here are all allowed `event` strings that defined in `OnboardingTelemetry::EVENT_WHITELIST`.
### Session events

| EVENT | DESCRIPTION |
|-----------|---------------------|
| `onboarding-register-session` | internal event triggered to register a new page session. Called when the onboarding script is inited in a browser tab. Will not send out any data. |
| `onboarding-session-begin` | internal event triggered when the onboarding script is inited, will not send out any data. |
| `onboarding-session-end` | internal event triggered when the onboarding script is destoryed. `onboarding-session` event is sent to the server. |
| `onboarding-session` | event is sent when the onboarding script is destoryed |

### Overlay events

| EVENT | DESCRIPTION |
|-----------|---------------------|
| `overlay-session-begin` | internal event triggered when user open the overlay, will not send out any data. |
| `overlay-session-end` | internal event is triggered when user close the overlay. `overlay-session` event is sent to the server. |
| `overlay-session` | event is sent when user close the overlay |
| `overlay-nav-click` | event is sent when click or auto select the overlay navigate item |
| `overlay-cta-click` | event is sent when user click the overlay CTA button |
| `overlay-skip-tour` | event is sent when click the overlay `skip tour` button |

### Notification events

| EVENT | DESCRIPTION |
|-----------|---------------------|
| `notification-session-begin` | internal event triggered when user open the notification, will not send out any data. |
| `notification-session-end` | internal event is triggered when user close the notification. `notification-session` event is sent to the server. |
| `notification-session` | event is sent when user close the notification |
| `notification-close-button-click` | event is sent when click the notification close button |
| `notification-cta-click` | event is sent when click the notification CTA button |

