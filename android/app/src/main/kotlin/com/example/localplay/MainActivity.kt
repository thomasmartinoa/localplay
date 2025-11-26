package com.example.localplay

import android.media.MediaMetadataRetriever
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.localplay/artwork"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "extractArtwork" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    val artwork = extractArtwork(filePath)
                    result.success(artwork)
                }
                "extractMetadata" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath == null) {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    val metadata = extractMetadata(filePath)
                    result.success(metadata)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun extractArtwork(filePath: String): ByteArray? {
        val retriever = MediaMetadataRetriever()
        return try {
            val file = File(filePath)
            if (!file.exists()) {
                return null
            }
            
            retriever.setDataSource(filePath)
            retriever.embeddedPicture
        } catch (e: Exception) {
            e.printStackTrace()
            null
        } finally {
            try {
                retriever.release()
            } catch (e: Exception) {
                // Ignore release errors
            }
        }
    }

    private fun extractMetadata(filePath: String): Map<String, Any?>? {
        val retriever = MediaMetadataRetriever()
        return try {
            val file = File(filePath)
            if (!file.exists()) {
                return null
            }
            
            retriever.setDataSource(filePath)
            
            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            val album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
            val albumArtist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            val year = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_YEAR)
            val trackNumber = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
            val discNumber = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DISC_NUMBER)
            val genre = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_GENRE)
            val composer = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_COMPOSER)
            val bitrate = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_BITRATE)
            
            mapOf(
                "title" to title,
                "artist" to artist,
                "album" to album,
                "albumArtist" to albumArtist,
                "duration" to duration?.toLongOrNull(),
                "year" to year?.toIntOrNull(),
                "trackNumber" to parseTrackNumber(trackNumber),
                "discNumber" to parseTrackNumber(discNumber),
                "genre" to genre,
                "composer" to composer,
                "bitrate" to bitrate?.toLongOrNull(),
                "hasArtwork" to (retriever.embeddedPicture != null)
            )
        } catch (e: Exception) {
            e.printStackTrace()
            null
        } finally {
            try {
                retriever.release()
            } catch (e: Exception) {
                // Ignore release errors
            }
        }
    }

    private fun parseTrackNumber(trackStr: String?): Int? {
        if (trackStr == null) return null
        // Handle formats like "1/12" or just "1"
        return trackStr.split("/").firstOrNull()?.trim()?.toIntOrNull()
    }
}
