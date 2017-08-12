angular.module('loomioApp').directive 'commentForm', ($translate) ->
  scope: {discussion: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/comment_form/comment_form.html'
  replace: true
  controller: ($scope, $rootScope, FormService, Records, Session, KeyEventService, AbilityService, MentionService, AttachmentService, ScrollService, EmojiService, ModalService, AuthModal) ->

    $scope.showCommentForm = ->
      AbilityService.canAddComment($scope.discussion)

    $scope.commentPlaceholder = ->
      if $scope.comment.parentId
        $translate.instant('comment_form.in_reply_to', name: $scope.comment.parent().authorName())
      else
        $translate.instant('comment_form.say_something')

    $scope.isLoggedIn = AbilityService.isLoggedIn

    $scope.signIn = ->
      ModalService.open AuthModal

    $scope.threadIsPublic = ->
      $scope.discussion.private == false

    $scope.threadIsPrivate = ->
      $scope.discussion.private == true

    successMessage = ->
      if $scope.comment.isReply()
        'comment_form.messages.replied'
      else
        'comment_form.messages.created'
    successMessageName = ->
      if $scope.comment.isReply()
        $scope.comment.parent().authorName()

    $scope.listenForSubmitOnEnter = ->
      KeyEventService.submitOnEnter $scope

    $scope.init = ->
      $scope.comment = Records.comments.build(discussionId: $scope.discussion.id, authorId: Session.user().id)
      $scope.submit = FormService.submit $scope, $scope.comment,
        drafts: true
        submitFn: $scope.comment.save
        flashSuccess: successMessage
        flashOptions:
          name: successMessageName
        successCallback: $scope.init
      $scope.listenForSubmitOnEnter()
      $scope.$broadcast 'commentFormInit', $scope.comment
    $scope.init()

    $scope.$on 'replyToCommentClicked', (event, parentComment) ->
      $scope.comment.parentId = parentComment.id
      $scope.comment.parentAuthorName = parentComment.authorName()
      ScrollService.scrollTo('.comment-form__comment-field', offset: 150)

    $scope.bodySelector = '.comment-form__comment-field'
    EmojiService.listen $scope, $scope.comment, 'body', $scope.bodySelector
    AttachmentService.listenForPaste $scope
    MentionService.applyMentions $scope, $scope.comment
    AttachmentService.listenForAttachments $scope, $scope.comment
