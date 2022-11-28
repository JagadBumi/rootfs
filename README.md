# How to install Ubuntu on termux
<pre><code>pkg install wget openssl-tool proot -y</code></pre>
<pre><code>wget -O- https://raw.githubusercontent.com/JagadBumi/rootfs/main/ubuntu.sh | bash</code></pre>

# Launch Ubuntu with the ./start-ubuntu.sh script
<pre><code>./start-ubuntu.sh</code></pre>
<pre><code>apt update && apt upgrade</code></pre>
<pre><code>apt-get update && apt-get upgrade</code></pre>


# How to install Debian on termux
<pre><code>pkg install wget openssl-tool proot -y</code></pre>
<pre><code>wget -O- https://raw.githubusercontent.com/JagadBumi/rootfs/main/debian.sh | bash</code></pre>

# Launch Debian with the ./start-debian.sh script
<pre><code>./start-debian.sh</code></pre>
<pre><code>apt update && apt upgrade</code></pre>
<pre><code>apt-get update && apt-get upgrade</code></pre>
