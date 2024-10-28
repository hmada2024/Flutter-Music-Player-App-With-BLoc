import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music/db_helper/db_helper.dart';
import 'package:music/model/audio_file_model.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final AudioPlayer player;
  bool isPlaying = false;
  Timer? timer;
  final dbHelper = DbHelper();

  PlayerBloc({
    required this.player,
  }) : super(const PlayerState()) {
    on(_onPlayPauseEvent);
    on(_onPlayEvent);
    on(_progressUpdate);
    on(_onTapFavouriteEvent);
    on(_onTapForwardEvent);
    on(_onTapBackwardEvent);
  }

  Future<void> _onPlayPauseEvent(
      PlayPauseEvent event, Emitter<PlayerState> emit) async {
    if (isPlaying) {
      player.pause();
      emit(state.copyWith(
        isPlaying: false,
      ));
    } else {
      player.play();
      emit(state.copyWith(
        isPlaying: true,
      ));
    }
    isPlaying = event.isPlaying;
  }

  Future<void> _onPlayEvent(
      OnPlayEvent event, Emitter<PlayerState> emit) async {
    await player.setFilePath(event.file.path.toString());
    player.play();
    isPlaying = true;
    double progress = 0.0;
    emit(state.copyWith(
        isPlaying: true,
        isFavourite: event.file.isFavourite == 1,
        status: SongStatus.playing,
        file: event.file));
    Timer.periodic(const Duration(milliseconds: 1), (timer) {
      progress = player.duration == null
          ? 0.0
          : player.position.inMilliseconds / player.duration!.inMilliseconds;
      add(ProgressUpdateEvent(progress: progress));
      if (progress >= 1.0) {
        timer.cancel();
      }
    });
  }

  Future<void> _progressUpdate(
      ProgressUpdateEvent event, Emitter<PlayerState> emit) async {
    if (event.progress == 1.0) {
      // player.pause();
      // player.seek(const Duration(seconds: 0));
      // emit(state.copyWith(progress: 0.0,isPlaying: false));
      add(OnPlayEvent(file: state.file!));
    } else {
      emit(state.copyWith(
        progress: event.progress,
      ));
    }
  }

  Future<void> _onTapFavouriteEvent(
    OnTapFavouriteEvent event, Emitter<PlayerState> emit) async {
  try {
    // التحقق إذا كان الملف موجوداً بالفعل في قائمة المفضلة
    final alreadyExist = await dbHelper.isFavoriteExists(event.file.name.toString());

    // إذا كان الملف موجوداً
    if (alreadyExist) {
      // التحقق إذا كانت الواجهة لا تزال متصلة بالشجرة لتجنب الأخطاء
      if (!event.context.mounted) return; // التأكد من صلاحية الـcontext

      // إظهار مربع الحوار التحذيري
      showDialog(
        context: event.context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              'تحذير',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
            content: const Text(
              'هذا الملف موجود بالفعل في قائمة المفضلة، هل تريد حذفه؟',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
            actions: [
              // زر الإلغاء
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  )),
              const SizedBox(
                width: 10,
              ),
              // زر التأكيد لحذف الملف
              InkWell(
                onTap: () async {
                  // حذف الملف من قاعدة البيانات
                  await dbHelper.delete(event.file.name.toString());
                  // التحقق من صلاحية الـcontext قبل إغلاق مربع الحوار
                  if (event.context.mounted) Navigator.pop(context);
                  // تحديث الحالة لتظهر أن الملف لم يعد في المفضلة
                  emit(state.copyWith(isFavourite: false));
                },
                child: const Text(
                  'موافق',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // إذا لم يكن الملف موجوداً في قائمة المفضلة، يتم إضافته
      await dbHelper.insert(event.file);
      // تحديث الحالة لتظهر أن الملف تم إضافته إلى المفضلة
      emit(state.copyWith(isFavourite: true));
    }
  } catch (e) {
    // التعامل مع الأخطاء في حالة وجود مشكلة في العملية
    if (kDebugMode) {
      print("حدث خطأ في التعامل مع المفضلة: $e");
    }
  }
}



  void _onTapForwardEvent(OnTapForwardEvent event, Emitter<PlayerState> emit) {
    if (player.position.inSeconds < player.duration!.inSeconds - 10) {
      player.seek(Duration(seconds: player.position.inSeconds + 10));
      emit(state.copyWith(
          progress: player.position.inMilliseconds /
              player.duration!.inMilliseconds));
    }
  }

  void _onTapBackwardEvent(
      OnTapBackwardEvent event, Emitter<PlayerState> emit) {
    if (player.position.inSeconds > 10) {
      player.seek(Duration(seconds: player.position.inSeconds - 10));
    } else {
      player.seek(const Duration(seconds: 0));
    }
    emit(state.copyWith(
        progress:
            player.position.inMilliseconds / player.duration!.inMilliseconds));
  }
}
