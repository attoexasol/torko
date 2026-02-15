class Urls{

    static const _baseUrL = "https://torko.attoexasolutions.com/api";

    static const create_users = "$_baseUrL/create_users" ;
    static const single_users = "$_baseUrL/single_users" ;
    static const delete_users = "$_baseUrL/delete_users" ;
    static const verify_otp = "$_baseUrL/verify_otp" ;
    static const update_users = "$_baseUrL/update_users" ;
    static const profile_image = "$_baseUrL/profile_image_update" ;
    static const cover_image = "$_baseUrL/cover_image_update" ;
    static const notifications = "$_baseUrL/update_notifications" ;
    static const privacy_settings = "$_baseUrL/update_privacy_settings" ;


    // Post API endPoints
    static const create_post = "$_baseUrL/create_post" ;
    static const update_post = "$_baseUrL/update_post" ;
    static const single_post = "$_baseUrL/single_post" ;
    static const delete_post = "$_baseUrL/delete_post" ;
    static const user_own_posts = "$_baseUrL/user/posts" ;

    static const save_post = "$_baseUrL/create/save_post" ;
    static const get_save_post = "$_baseUrL/get/save_post" ;
    static const unsave_post = "$_baseUrL/create/unsave_post";


    // Comment API endPoints
    static const get_all_comment = "$_baseUrL/get_all_comment" ;
    static const single_comment = "$_baseUrL/single_comment" ;
    static const create_comment = "$_baseUrL/create_comment" ;
    static const update_comment = "$_baseUrL/update_comment" ;
    static const delete_comment = "$_baseUrL/delete_comment" ;

    // Share post
    static const share_post = "$_baseUrL/create/share_post" ;
    static const delete_share_post = "$_baseUrL/delete/share_post" ;



    // Feed page
    static const get_all_post = "$_baseUrL/get_all_post" ;

    // like
    static const like_create = "$_baseUrL/like_create" ;


    // Community groups
    static const create_group = "$_baseUrL/community-groups/create" ;
    static const get_all_groups = "$_baseUrL/get-all-community-groups";
    static const get_single_group = "$_baseUrL/community-groups/single";
    static const Update_Group = "$_baseUrL/community-groups/update";     // POST Method
    static const delete_Group = "$_baseUrL/community-group/delete";     // POST Method

    static const create_Group_post = "$_baseUrL/group-posts/create";     // POST Method
    static const update_Group_post_post = "$_baseUrL/update_post" ;
    static const delete_Group_post_post = "$_baseUrL/delete_post" ;


    static const Approve_Member = "$_baseUrL/group/member/status" ;
    static const Get_All_Group_Members = "$_baseUrL/group/member/get-all-members" ;    // GET
    static const Leave_Group = "$_baseUrL/group/member/leave" ;
    static const Delete_Group_Member = "$_baseUrL/group/member/delete" ;



    // Send Message
    static const send_message = "$_baseUrL/messages/send" ;
    static const get_Message_API = "$_baseUrL/messages" ;
    static const get_Single_Message_API = "$_baseUrL/single/message" ;
    static const message_search = "$_baseUrL/search/message" ;

    // Broadcasting Auth (Pusher/Reverb protocol)
    static const pusher_auth = "$_baseUrL/broadcasting/auth";
    static const broadcastingAuth = pusher_auth;

    //  friends
    static const friend_request = "$_baseUrL/friend/request" ;
    static const accept_friend_request = "$_baseUrL/friend/accept" ;
    static const reject_friend_reject = "$_baseUrL/friend/reject" ;
    static const pending_friend_requests = "$_baseUrL/friend/requests" ;
    /// Requests tab: incoming pending friend requests.
    static const incoming_friend_requests = "$_baseUrL/friend/requests";
    /// Send tab: outgoing sent friend requests.
    static const sent_friend_requests = "$_baseUrL/friend/requests-sended";
    static const cancel_friend_requests = "$_baseUrL/friend/cancel-or-delete" ;
    static const friend_lists = "$_baseUrL/friends" ;
    static const friend_search = "$_baseUrL/friends/search" ;
    static const mutual_friend_suggestion = "$_baseUrL/friends/mutual-suggestions" ;


}
