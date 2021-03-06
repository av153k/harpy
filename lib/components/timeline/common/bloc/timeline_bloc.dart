import 'dart:async';

import 'package:dart_twitter_api/api/tweets/timeline_service.dart';
import 'package:dart_twitter_api/twitter_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:harpy/components/timeline/common/bloc/timeline_event.dart';
import 'package:harpy/components/timeline/common/bloc/timeline_state.dart';
import 'package:harpy/core/api/twitter/tweet_data.dart';
import 'package:harpy/core/service_locator.dart';

abstract class TimelineBloc extends Bloc<TimelineEvent, TimelineState> {
  TimelineBloc() : super(UninitializedState());

  final TimelineService timelineService = app<TwitterApi>().timelineService;

  /// The [tweets] for this timeline.
  List<TweetData> tweets = <TweetData>[];

  /// Completes when the timeline has been updated using [UpdateTimelineEvent].
  Completer<void> updateTimelineCompleter = Completer<void>();

  /// Completes when more tweets for the timeline has been requested using
  /// [RequestMoreTimelineEvent].
  Completer<void> requestMoreCompleter = Completer<void>();

  /// `True` when [RequestMoreTimelineEvent] requests should be locked.
  bool lockRequestMore = false;

  /// Whether the tweet list should be able to request more.
  bool get enableRequestMore =>
      state is ShowingTimelineState && !lockRequestMore;

  /// Whether a loading widget should be shown.
  bool get showLoading => state is UpdatingTimelineState && tweets.isEmpty;

  /// Whether a failed request widget should be shown.
  bool get showFailed => state is FailedLoadingTimelineState && tweets.isEmpty;

  @override
  Stream<TimelineState> mapEventToState(
    TimelineEvent event,
  ) async* {
    yield* event.applyAsync(currentState: state, bloc: this);
  }
}
