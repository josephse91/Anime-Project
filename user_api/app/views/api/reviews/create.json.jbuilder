json.status "complete"
json.review do |attribute|
    attribute.user @review.user
    attribute.show @review.show
    attribute.rating @review.rating
    attribute.amount_watched @review.amount_watched
    attribute.highlighted_points @review.highlighted_points
    attribute.overall_review @review.overall_review
    attribute.referral_id @review.referral_id
    attribute.watch_priority @review.watch_priority
end