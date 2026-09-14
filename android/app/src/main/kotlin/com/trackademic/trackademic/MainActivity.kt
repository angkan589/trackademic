package com.trackademic.trackademic

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val reportChannel = "trackademic/report_export"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, reportChannel)
            .setMethodCallHandler { call, result ->
                if (call.method != "saveCsv") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val fileName = call.argument<String>("fileName")
                val content = call.argument<String>("content")

                if (fileName.isNullOrBlank() || content == null) {
                    result.error("invalid_arguments", "A file name and report content are required.", null)
                    return@setMethodCallHandler
                }

                try {
                    result.success(saveCsv(fileName, content))
                } catch (error: Exception) {
                    result.error("save_failed", error.message ?: "The report could not be saved.", null)
                }
            }
    }

    private fun saveCsv(fileName: String, content: String): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val values = ContentValues().apply {
                put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
                put(MediaStore.MediaColumns.MIME_TYPE, "text/csv")
                put(
                    MediaStore.MediaColumns.RELATIVE_PATH,
                    "${Environment.DIRECTORY_DOWNLOADS}/Trackademic",
                )
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }

            val uri = contentResolver.insert(
                MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                values,
            ) ?: error("Android could not create the report file.")

            try {
                contentResolver.openOutputStream(uri)?.bufferedWriter(Charsets.UTF_8).use { writer ->
                    requireNotNull(writer) { "Android could not open the report file." }
                    writer.write("\uFEFF")
                    writer.write(content)
                }

                values.clear()
                values.put(MediaStore.MediaColumns.IS_PENDING, 0)
                contentResolver.update(uri, values, null, null)
                return "Downloads/Trackademic/$fileName"
            } catch (error: Exception) {
                contentResolver.delete(uri, null, null)
                throw error
            }
        }

        @Suppress("DEPRECATION")
        val downloads = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_DOWNLOADS,
        )
        val folder = File(downloads, "Trackademic")
        check(folder.exists() || folder.mkdirs()) {
            "Android could not create the Trackademic download folder."
        }

        val output = File(folder, fileName)
        output.writeText("\uFEFF$content", Charsets.UTF_8)
        return output.absolutePath
    }
}
