# export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# # For compilers to find openjdk you may need to set:
# export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
# export JAVA_HOME=$(/usr/libexec/java_home)

# # For the system Java wrappers to find this JDK, symlink it with
# # sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk


if [ -f /usr/libexec/java_home ] && [ -f $HOME/flink ]; then
  export JAVA_HOME=$(/usr/libexec/java_home -v 17)
  export PATH=$JAVA_HOME/bin:$PATH
else
  # sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
fi

if [ -d $HOME/flink ]; then
  export FLINK_HOME=$HOME/flink/flink-2.0.0
  export PATH=$FLINK_HOME/bin:$PATH
else
  # sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
fi
