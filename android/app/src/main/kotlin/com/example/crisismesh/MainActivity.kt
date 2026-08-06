package com.example.crisismesh

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.genai.llminference.LlmInference
import com.google.mediapipe.tasks.genai.llminference.ConstrainedDecodingConfig
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {
    private var llmInference: LlmInference? = null
    private val CHANNEL = "com.crisismesh.ai"
    
    // JSON Schema for constrained decoding - must match TRIAGE_JSON_SCHEMA in prompts.dart
    private val TRIAGE_JSON_SCHEMA = """
    {
      "type": "object",
      "required": ["reply", "chips", "flag_urgent", "in_scope"],
      "properties": {
        "reply": {"type": "string"},
        "chips": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["label", "action"],
            "properties": {
              "label": {"type": "string"},
              "action": {"type": "string", "enum": ["continue_","escalate","locate","dismiss"]},
              "payload": {"type": "object"}
            }
          }
        },
        "flag_urgent": {"type": "boolean"},
        "in_scope": {"type": "boolean"}
      }
    }
    """.trimIndent()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initGemma" -> {
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val modelFile = File(context.cacheDir, "gemma.task")
                            if (!modelFile.exists()) {
                                context.assets.open("gemma.task").use { input ->
                                    FileOutputStream(modelFile).use { output ->
                                        input.copyTo(output)
                                    }
                                }
                            }
                            
                            val constrainedDecoding = ConstrainedDecodingConfig.builder()
                                .setJsonSchema(TRIAGE_JSON_SCHEMA)
                                .build()
                            
                            val options = LlmInference.LlmInferenceOptions.builder()
                                .setModelPath(modelFile.absolutePath)
                                .setMaxTokens(512)
                                .setConstrainedDecodingConfig(constrainedDecoding)
                                .build()
                            
                            llmInference = LlmInference.createFromOptions(context, options)
                            withContext(Dispatchers.Main) {
                                result.success(true)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("INIT_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "generateResponse" -> {
                    val prompt = call.argument<String>("prompt")
                    if (prompt == null) {
                        result.error("INVALID_ARGUMENT", "Prompt cannot be null", null)
                        return@setMethodCallHandler
                    }
                    
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            val response = llmInference?.generateResponse(prompt)
                            withContext(Dispatchers.Main) {
                                result.success(response ?: "Error: Engine not initialized.")
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("GENERATE_FAILED", e.message, null)
                            }
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
