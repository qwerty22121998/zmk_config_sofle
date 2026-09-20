/*
 * CONFIG_ZMK_DISPLAY_KEEP_ON_USB: keep the display on while idle if USB powered.
 * ZMK's own idle listener still queues the blank; this undoes it on the display work queue.
 */

#include <zephyr/kernel.h>

#include <zmk/activity.h>
#include <zmk/display.h>
#include <zmk/event_manager.h>
#include <zmk/events/activity_state_changed.h>
#include <zmk/events/usb_conn_state_changed.h>
#include <zmk/usb.h>

// non-static internals of ZMK v0.3 app/src/display/main.c, no header; recheck on ZMK bumps
extern struct k_work blank_display_work;
void blank_display_cb(struct k_work *work);
void unblank_display_cb(struct k_work *work);

static void keep_on_usb_cb(struct k_work *work) {
    if (zmk_activity_get_state() == ZMK_ACTIVITY_ACTIVE) {
        return;
    }

    if (zmk_usb_is_powered()) {
        // Drop ZMK's queued blank; if it already ran, the display blinks off for a moment
        k_work_cancel(&blank_display_work);
        unblank_display_cb(work);
    } else {
        // Unplugged while idle
        blank_display_cb(work);
    }
}

static K_WORK_DEFINE(keep_on_usb_work, keep_on_usb_cb);

static int keep_on_usb_listener(const zmk_event_t *eh) {
    k_work_submit_to_queue(zmk_display_work_q(), &keep_on_usb_work);
    return ZMK_EV_EVENT_BUBBLE;
}

ZMK_LISTENER(display_keep_on_usb, keep_on_usb_listener);
ZMK_SUBSCRIPTION(display_keep_on_usb, zmk_activity_state_changed);
ZMK_SUBSCRIPTION(display_keep_on_usb, zmk_usb_conn_state_changed);
