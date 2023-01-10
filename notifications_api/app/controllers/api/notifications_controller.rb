class Api::NotificationsController < ApplicationController

    def index
        notifications = Notification.all

        if !notifications
            render json: {status: "failed", error: notifications.errors.objects.first.full_message}
            return
        end

        render json: {status: "complete", notifications: notifications}
    end

    def create
        notification = ActiveSupport::JSON.decode(notification_params[:notification])

        event_action = notification["action"].downcase
        target = notification["target_item"].downcase
        target_id = notification["id"]
        action_user = notification["action_user"]
        recipient = notification["recipient"]

        time_block = Time.now - 60.second

        where_query = ""
        where_query += "notifications.target = ? "
        where_query += "AND notifications.target_id = ? "
        where_query += "AND notifications.recipient = ? "
        where_query += "AND notifications.updated_at > ?"

        exact_check = "target = ? AND target_id = ? AND recipient = ? AND action_user = ?"

        exact_notification = Notification.where([exact_check,target,target_id,recipient,action_user]).take

        similar_n = Notification.where([where_query,target,target_id,recipient,time_block]).order(updated_at: :desc)

        common_actions = similar_n.length > 0 ? similar_n.first.common_actions + 1 : 0
        
        if similar_n.length > 0 
            last_selected = similar_n.first
            
            if similar_n.include?(exact_notification)
                common_actions -= 1
            end

            last_selected.selected = false
            last_selected.save
        end

        message = write_notification(notification,common_actions)

        if exact_notification
            exact_notification.update({
                updated_at: Time.now, 
                seen: false, 
                common_actions: common_actions,
                message: message,
                selected: true
            })

            render json: {status: "complete", notification: exact_notification, note: "Renewed existing notification"}
            return
        end

        new_notification = Notification.new({
            event_action: event_action,
            target: target,
            target_id: target_id,
            action_user: action_user,
            recipient: recipient,
            common_actions: common_actions,
            message: message,
            selected: true
        })

        if new_notification.invalid?
            render json: {status: "failed", error: new_notification.errors.objects.first.full_message}
            return
        end

        new_notification.save

        render json: {status: "complete", notification: new_notification}
    end

    def new_notifications
        recipient = "'#{notification_params[:id]}'"

        sql = <<-SQL 
        SELECT COUNT(*) AS Notifications
        FROM notifications
        WHERE notifications.recipient = #{recipient} AND selected AND seen = '0'
        GROUP BY recipient
        SQL

        notification_count = Notification.find_by_sql(sql)

        render json: {status: "complete", notification_count: notification_count}
    end

    def show
        recipient = notification_params[:id]

        notifications = Notification.where(recipient: recipient).order(updated_at: :desc)

        render json: {status: "complete", notifications: notifications}
    end

    def update
        recipient = notification_params[:id]

        notifications = Notification.where(recipient: recipient).order(updated_at: :desc).limit(20)

        unseen_notifications = notifications.where(seen: false).length
        old_notifications = notifications[0...unseen_notifications]
        new_notifications = notifications[unseen_notifications..-1]
        
        notifications.update_all(seen: true)

        if !notifications
            render json: {status: "failed", error: "Notifications could not be updated"}
            return
        end

        render json: {status: "complete", notifications: notifications, new_notifications: new_notifications, old_notifications: old_notifications}

    end

    def write_notification(notification,common_actions)
        event_action = notification["action"].downcase
        target_item = notification["target_item"].downcase
        action_user = notification["action_user"]

        message = ""
        action_user = common_actions > 0 ? "#{common_actions + 1} users" : action_user

        if event_action == "sent a request"
            message = "#{action_user} sent you a peer request"
        end

        if event_action == "accepted request"
            message = "#{action_user} accepted your peer request"
        end

        if event_action == "requested to join"
            message = "#{action_user} is requesting to join room: #{notification["room"]}"
        end

        if event_action == "accepted request to join"
            message = "Your are now in room: #{action_user}"
        end

        if event_action == "created a forum post"
            message = "#{action_user} created a forum post in room: #{notification["room"]}"
        end

        if event_action == "like" && (target_item == "review" || target_item == "review comment")
            message = "#{action_user} liked your #{target_item} for #{notification["show"]}"
        end

        if event_action == "like" && (target_item == "forum" || target_item == "forum comment")
            message = "#{action_user} liked your #{target_item} in #{notification["room"]}"
        end

        if event_action == "comment" && (target_item == "review" || target_item == "review comment")
            message = "#{action_user} commented on your #{target_item} for #{notification["show"]}"
        end

        if event_action == "comment" && (target_item == "forum" || target_item == "forum comment")
            message = "#{action_user} commented on your #{target_item} in #{notification["room"]}"
        end

        if event_action == "accepted recommendation"
            message = "#{action_user} accepted your #{target_item} for #{notification["show"]}"
        end

        if event_action == "recommendation sent"
            message = "#{action_user} sent you a #{target_item} for #{notification["show"]}"
        end
        message
    end

    def notification_params
        params.permit(:id,:notification)
    end
end
