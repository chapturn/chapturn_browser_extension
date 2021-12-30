import 'package:chapturn_browser_extension/core/novel/notifiers/chapter_state.dart';
import 'package:chapturn_browser_extension/core/novel/providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ChaptersCard extends ConsumerWidget {
  const ChaptersCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterCount = ref.watch(chapterCountProvider);
    final isMulti = ref.watch(isMultiVolumeProvider);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '$chapterCount chapters',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          isMulti ? const MultiVolumeView() : const SingleVolumeView(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class MultiVolumeView extends ConsumerWidget {
  const MultiVolumeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterCount = ref.watch(chapterCountProvider);
    final multiVolume = ref.watch(multiVolumeProvider);

    var limit = chapterCount > 40;
    Widget child = ListView.builder(
      itemCount: multiVolume.length,
      itemBuilder: (context, i) => multiVolume[i].when(
        volume: (volume) => ListTile(title: Text(volume.name)),
        chapter: (chapter) => ProviderScope(
          overrides: [
            chapterProvider.overrideWithValue(chapter),
          ],
          child: const ChapterTile(),
        ),
      ),
      shrinkWrap: !limit,
    );

    if (limit) {
      child = LimitedBox(
        maxHeight: MediaQuery.of(context).size.height,
        child: child,
      );
    }

    return child;
  }
}

class SingleVolumeView extends ConsumerWidget {
  const SingleVolumeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterCount = ref.watch(chapterCountProvider);
    final chapters = ref.watch(singleVolumeProvider);
    final limit = chapterCount > 40;

    Widget child = ListView.builder(
      itemCount: chapters.length,
      itemBuilder: (context, i) => ProviderScope(
        overrides: [
          chapterProvider.overrideWithValue(chapters[i]),
        ],
        child: const ChapterTile(),
      ),
      shrinkWrap: !limit,
    );

    if (limit) {
      child = LimitedBox(
        maxHeight: MediaQuery.of(context).size.height,
        child: child,
      );
    }

    return child;
  }
}

class ChapterTile extends ConsumerWidget {
  const ChapterTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(chapterProvider);
    final chapterState = ref.watch(chapterStateProvider(chapter));

    return CheckboxListTile(
      title: Text(chapter.title),
      subtitle: Text(chapter.updated?.toString() ?? '<unknown>'),
      secondary: Icon(tileIcon(chapterState.downloadDisplayState)),
      value: chapterState.isSelected,
      onChanged: (value) =>
          ref.read(chapterStateProvider(chapter).notifier).toggle(value),
      // onChanged: (value) =>
      //     ref.read(chapterListProvider.notifier).toggle(chapter.index, value),
    );

    // false
    //       ? null
    //       : (value) => ref
    //           .read(chapterListProvider.notifier)
    //           .select(chapterState.volumeIndex, chapter.index, value)
  }

  IconData tileIcon(ChapterDownloadState state) {
    switch (state) {
      case ChapterDownloadState.pending:
        return Icons.download;
      case ChapterDownloadState.unselected:
        return Icons.cancel;
      case ChapterDownloadState.inProgress:
        return Icons.downloading;
      case ChapterDownloadState.complete:
        return Icons.download_done;
    }
  }
}
