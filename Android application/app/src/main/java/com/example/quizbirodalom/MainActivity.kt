package com.example.webview_kotlin

import android.Manifest
import android.app.DownloadManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.view.View
import android.webkit.*
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import com.example.quizbirodalom.AlarmUtils
import kotlinx.android.synthetic.main.activity_main.*
import java.util.*


class MainActivity : AppCompatActivity() {

    var url = "https://31.5.236.7/"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        try {
            this.supportActionBar!!.hide()
        } catch (e: NullPointerException) {
        }
        setContentView(R.layout.activity_main)

        val calendar = Calendar.getInstance()
        val alarmUtils = AlarmUtils(this)
        alarmUtils.initRepeatingAlarm(calendar)

        Thread(Runnable {
            while (true) {
                runOnUiThread{
                    var wv = findViewById<View>(R.id.webView)
                    var nc = findViewById<View>(R.id.noConn)
                    if(!checkForInternet(this))
                    {
                        Toast.makeText(this, "Internet connection lost. Reconnecting...", Toast.LENGTH_LONG).show()
                        wv.visibility = View.INVISIBLE
                        nc.visibility = View.VISIBLE
                    }
                    else
                    {
                        wv.visibility = View.VISIBLE
                        nc.visibility = View.INVISIBLE
                    }
                }

                Thread.sleep(5000)
            }
        }).start()

        webView.webViewClient = WebViewClient()

        webView.setDownloadListener { url, userAgent, contentDisposition, mimetype, _ ->
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                if (checkSelfPermission(Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
                    //Do this, if permission granted
                    downloadDialog(url, userAgent, contentDisposition, mimetype)
                } else {
                    //Do this, if there is no permission
                    ActivityCompat.requestPermissions(
                        this,
                        arrayOf(Manifest.permission.WRITE_EXTERNAL_STORAGE),
                        1
                    )
                }
            } else {
                //Code for devices below API 23 or Marshmallow
                downloadDialog(url, userAgent, contentDisposition, mimetype)
            }
        }

        webView.setWebViewClient(object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url_: String): Boolean {
                try {
                    if(url_.startsWith(url)){
                        return false
                    }
                    if (url_.startsWith("http:") || url_.startsWith("https:")) {
                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url_))
                        startActivity(intent)
                    } else {
                        return false
                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                return true
            }
        })



        webView.getSettings().setMediaPlaybackRequiresUserGesture(false);

        webView.setInitialScale(1);
        webView.settings.setJavaScriptEnabled(true);
        webView.settings.javaScriptCanOpenWindowsAutomatically = true
        webView.settings.setSupportMultipleWindows(true)
        webView.settings.setLoadWithOverviewMode(true)
        webView.settings.setUseWideViewPort(true)

        webView.settings.builtInZoomControls = true
        webView.settings.setSupportZoom(true) // if you want to enable zoom feature
        webView.setScrollBarStyle(WebView.SCROLLBARS_OUTSIDE_OVERLAY);
        webView.setScrollbarFadingEnabled(false);

        webView.setWebChromeClient(WebChromeClient()) // for alert popups

        webView.settings.setDomStorageEnabled(true)
        webView.settings.setAllowContentAccess(true)
        webView.settings.setAllowFileAccess(true)

        webView.settings.domStorageEnabled = true
        webView.settings.allowContentAccess = true
        webView.settings.allowFileAccess = true

        webView.settings.setSupportMultipleWindows(true)
        webView.settings.setDisplayZoomControls(false)

        webView.getSettings().setCacheMode(WebSettings.LOAD_NO_CACHE);

        webView.loadUrl(url)
    }



    fun downloadDialog(url:String,userAgent:String,contentDisposition:String,mimetype:String)
    {
        val filename = URLUtil.guessFileName(url, contentDisposition, mimetype)
        val builder = AlertDialog.Builder(this@MainActivity)
        builder.setTitle("Fájl letöltése")
        if(filename.endsWith(".php")) {
            builder.setMessage("Szeretnéd menteni a kvíz eredményét PDF-ben?")
        }
        else {
            builder.setMessage("Szeretnéd menteni a fájlt?")
        }
        builder.setPositiveButton("Igen") { _, _ ->
            val request = DownloadManager.Request(Uri.parse(url))
            val cookie = CookieManager.getInstance().getCookie(url)
            request.addRequestHeader("Cookie",cookie)
            request.addRequestHeader("User-Agent",userAgent)
            //Download is visible and its progress, after completion too.
            request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
            val downloadmanager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
            if(filename.endsWith(".php")) {
                request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS,"doc.pdf")
            }
            else {
                request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS,filename)
            }
            downloadmanager.enqueue(request)
        }
        builder.setNegativeButton("Mégsem") {dialog, _ ->
            dialog.cancel()
        }
        val dialog:AlertDialog = builder.create()
        dialog.show()
    }


    private fun checkForInternet(context: Context): Boolean {
        // register activity with the connectivity manager service
        val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        // if the android version is equal to M
        // or greater we need to use the
        // NetworkCapabilities to check what type of
        // network has the internet connection
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {

            // Returns a Network object corresponding to
            // the currently active default data network.
            val network = connectivityManager.activeNetwork ?: return false

            // Representation of the capabilities of an active network.
            val activeNetwork = connectivityManager.getNetworkCapabilities(network) ?: return false

            return when {
                // Indicates this network uses a Wi-Fi transport,
                // or WiFi has network connectivity
                activeNetwork.hasTransport(NetworkCapabilities.TRANSPORT_WIFI) -> true

                // Indicates this network uses a Cellular transport. or
                // Cellular has network connectivity
                activeNetwork.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) -> true

                // else return false
                else -> false
            }
        } else {
            // if the android version is below M
            @Suppress("DEPRECATION") val networkInfo =
                connectivityManager.activeNetworkInfo ?: return false
            @Suppress("DEPRECATION")
            return networkInfo.isConnected
        }
    }



    // if you press Back button this code will work
    override fun onBackPressed() {
        // if your webview can go back it will go back
        if (webView.canGoBack())
            webView.goBack()
        // if your webview cannot go back
        // it will exit the application
        else
            super.onBackPressed()
    }

}

