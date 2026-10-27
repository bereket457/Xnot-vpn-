package com.xnot.vpn

import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import com.wireguard.android.backend.GoBackend
import com.wireguard.android.backend.Tunnel
import com.wireguard.config.Config
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.StringReader
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val channel = "xnot.vpn/service"
    private val executor = Executors.newSingleThreadExecutor()
    private lateinit var backend: GoBackend

    private val tunnel = object : Tunnel {
        override fun getName(): String = "XnotVPN"
        override fun onStateChange(newState: Tunnel.State) {}
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        backend = GoBackend(applicationContext)
    }

    override fun configureFlutterEngine(engine: FlutterEngine) {
        super.configureFlutterEngine(engine)

        MethodChannel(engine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "prepare" -> {
                        val intent = VpnService.prepare(this)
                        if (intent != null) {
                            startActivityForResult(intent, 7101)
                            result.success(false)
                        } else {
                            result.success(true)
                        }
                    }

                    "start" -> {
                        @Suppress("UNCHECKED_CAST")
                        val map = call.arguments as? Map<String, Any?>
                        if (map == null) {
                            result.error("BAD_CONFIG", "Missing VPN configuration", null)
                            return@setMethodCallHandler
                        }

                        executor.execute {
                            try {
                                val configText = buildWireGuardConfig(map)
                                val config = Config.parse(
                                    BufferedReader(StringReader(configText))
                                )
                                val state = backend.setState(
                                    tunnel,
                                    Tunnel.State.UP,
                                    config
                                )
                                runOnUiThread {
                                    result.success(state == Tunnel.State.UP)
                                }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error(
                                        "WG_START_FAILED",
                                        e.message ?: "WireGuard start failed",
                                        null
                                    )
                                }
                            }
                        }
                    }

                    "stop" -> {
                        executor.execute {
                            try {
                                backend.setState(tunnel, Tunnel.State.DOWN, null)
                                runOnUiThread { result.success(true) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error(
                                        "WG_STOP_FAILED",
                                        e.message ?: "WireGuard stop failed",
                                        null
                                    )
                                }
                            }
                        }
                    }

                    "stats" -> {
                        executor.execute {
                            try {
                                val stats = backend.getStatistics(tunnel)
                                runOnUiThread {
                                    result.success(
                                        mapOf(
                                            "rx" to stats.totalRx(),
                                            "tx" to stats.totalTx()
                                        )
                                    )
                                }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error(
                                        "WG_STATS_FAILED",
                                        e.message ?: "Statistics failed",
                                        null
                                    )
                                }
                            }
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun buildWireGuardConfig(map: Map<String, Any?>): String {
        fun str(key: String): String =
            map[key]?.toString()?.trim() ?: ""

        fun int(key: String, fallback: Int): Int =
            map[key]?.toString()?.toIntOrNull() ?: fallback

        val privateKey = str("wireguardPrivateKey")
        val address = str("wireguardAddress")
        val peerKey = str("wireguardPeerPublicKey")
        val endpoint = str("wireguardEndpoint")
        val allowed =
            str("wireguardAllowedIps").ifBlank { "0.0.0.0/0, ::/0" }
        val keepalive = int("wireguardKeepalive", 25)

        val dns = when (str("dns")) {
            "cloudflare" -> "1.1.1.1"
            "google" -> "8.8.8.8"
            "custom" -> str("customDns")
            else -> "1.1.1.1"
        }

        require(privateKey.isNotBlank()) {
            "WireGuard private key is required"
        }
        require(address.isNotBlank()) {
            "WireGuard interface address is required"
        }
        require(peerKey.isNotBlank()) {
            "WireGuard peer public key is required"
        }
        require(endpoint.isNotBlank()) {
            "WireGuard peer endpoint is required"
        }
        require(dns.isNotBlank()) {
            "DNS value is required"
        }

        return buildString {
            appendLine("[Interface]")
            appendLine("PrivateKey = $privateKey")
            appendLine("Address = $address")
            appendLine("DNS = $dns")
            appendLine("MTU = 1280")
            appendLine()
            appendLine("[Peer]")
            appendLine("PublicKey = $peerKey")
            appendLine("Endpoint = $endpoint")
            appendLine("AllowedIPs = $allowed")
            appendLine("PersistentKeepalive = $keepalive")
        }
    }

    override fun onDestroy() {
        executor.shutdownNow()
        super.onDestroy()
    }
}
