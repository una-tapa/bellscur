# Custom User Registry using bells feature

This sample shows how to prepare and configure Custom User Registry with Liberty server using `bells-1.0` feature. 

## Preparing Custom User Registry for bells feature

We will use `FileRegistrySample.java` that looks up `users.props` and `groups.props` files. 

```
# users.props
user0:user0pwd:500:001:user0
user1:user1pwd:500:001:user1
user2:user2pwd:502:002:user2
...
```

```
# groups.props
group1:001:user0,user1:group1
group2:002:user2,user6:group2
group3:003:user3:group3
...
```
The user registry `FileRegistrySample` contains the following lines as the props file location. 
```
private static String USERFILENAME = "/opt/ibm/wlp/usr/servers/defaultServer/resources/users.props";
private static String GROUPFILENAME = "/opt/ibm/wlp/usr/servers/defaultServer/resources/groups.props";
```

To package the user registry, go to the `java-project` directory and run mvn as follows.
```
cd java-project
mvn clean
mvn package
```
It will compile the user registry source code and create a jar file `bellscur-1.0-SNAPSHORT.jar` under `target` directory. 

The jar file includes a file named `META-INF/services/com.ibm.websphere.security.UserRegistry`. Inside the `com.ibm.websphere.security.UserRegistry` file, add one line that points to the UserRegistry class name. For this sample, the file contains one line below.
```
com.ibm.ws.samples.cur.FileRegistrySample
``` 
It tells Liberty which class to use as the user registry. 


## Configuring the Custom User Registry with bells

To use the jar with Liberty, first add the `bells-1.0` feature in the `featureManager` section.
```
<featureManager>
        <feature>bells-1.0</feature>
        <feature>webProfile-8.0</feature>
</featureManager>
```
Then add following `Library` section with the jar location, and place the jar in the location. 
In this sample, 
Also place `users.props` and `groups.props` where 

```
    <library id="bellsCurLib" name="bellsCurLib">
      <file name="${server.config.dir}/resources/sharedLib/bellsCur.jar"></file>
    </library>
    <bell libraryRef="bellsCurLib"></bell>
```
To test the Custom User Registry, we use a basicauth application. The application is configured to allow `user1` to login. The configuration is in the Liberty server.xml. 
```
    <application type="war" id="basicauth" location="${server.config.dir}/apps/basicauth.war">
    <application-bnd>
      <security-role name="Manager">
        <user name="user1"/>
        <group name="group3"/>
      </security-role>
    </application-bnd>
    </application>
```


## Running the server with the Custom User Registry


First, we will build the Custom User Registry. This creates `java-project/target/bellscur-1.0-SNAPSHOT.jar` that is ready to use with `bells-1.0` feature. 
```
cd java-project
mvn package
```
Next, let's build a docker image that use the jar. 
```
docker build -t bells .
```
Finally, run the docker container as follows. 
```
$ docker run -p 9080:9080 -p 9443:9443 bells
```
We can see the server launched. Note `bells-1.0` feature is enabled and the application URL is printed. Wait until the server is ready.

```
Launching defaultServer (WebSphere Application Server 21.0.0.9/wlp-1.0.56.cl210920210824-2341) on IBM J9 VM, version 8.0.6.36 - pxa6480sr6fp36-20210824_02(SR6 FP36) (en_US)
[AUDIT   ] CWWKE0001I: The server defaultServer has been launched.
...
[AUDIT   ] CWWKF0012I: The server installed the following features: [bells-1.0].
...
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://4e766d747a46:9080/basicauth/
...
[AUDIT   ] CWWKF0011I: The defaultServer server is ready to run a smarter planet. The defaultServer server started in 9.850 seconds.
```

From the browser, point to the application URL: 
http://localhost:9080/basicauth/servlet
The basic auth prompt appears. 
![BasicAuth prompto](/images/basicauth_prompt.png)
Enter userid `user1` and its password `user1pwd` as configured under the `users.props` and confirm the Custom User Registry is working.   
![user1 is logged in!](/images/UserLoggedIn.png)

## Summary 

The existing Custom User Registry for Traditional WebSpehre can be used with Liberty by following two steps: 
- Repackage the custom user registry jar with a file in META-INF
- Configure the Liberty server with `bells-1.0` and `Library` configuration that points to the custom user registry jar. 

### Note: 
- Using `bells-1.0` feature, the user registry is not able to read configurations in the server.xml. 
- If the user registry is created as an OSGi-feature (Not covered in this repository), it can read configuration from Liberty server.xml. 
- The environment variable can be used to configure values in server.xml and it can be read from the custom user registry using `bells-1.0`.  

```
Sample 1
<dataSource jndiName="jdbc/ds" >
    <jdbcDriver libraryRef="myJDBCDriver"/>
    <properties serverName="${env.DB_SERVER_NAME" etc.../>
  </dataSource>

export DB_SERVER_NAME=my.db.server.com   
```
```
# Sample 2
password="${env.passwordProp}" in server.xml and then System.getenv("passwordProp")
<jndiEntry jndiName=“password” value=“${password}“/>
```
#### Thanks
- @bwa @treo for assistance with pom.xml creation
- @aguibert @alasdair for the environment variable settings
