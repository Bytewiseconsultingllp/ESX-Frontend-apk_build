allprojects {
    repositories {
        google()
        mavenCentral()
        jcenter()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    project.afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.getByType(com.android.build.gradle.BaseExtension::class.java)
            
            // Set namespace if not already set
            if (android.namespace == null || android.namespace!!.isEmpty()) {
                val defaultNamespace = project.group.toString().replace(".", "_")
                android.namespace = defaultNamespace
            }

            // Enable buildConfig
            android.buildFeatures.apply {
                buildConfig = true  // Use property, not method
            }

            // Task to ensure namespace and remove package attribute
            project.tasks.register<DefaultTask>("fixManifestsAndNamespace") {
                doLast {
                    // Ensure namespace in build.gradle
                    val buildGradleFile = project.file("${project.projectDir}/build.gradle")
                    if (buildGradleFile.exists()) {
                        val buildGradleContent = buildGradleFile.readText()
                        val manifestFile = project.file("${project.projectDir}/src/main/AndroidManifest.xml")
                        if (manifestFile.exists()) {
                            val manifestContent = manifestFile.readText()
                            val packagePattern = "package=\"([^\"]+)\"".toRegex()
                            val packageMatch = packagePattern.find(manifestContent)
                            val packageName = packageMatch?.groupValues?.get(1)
                            if (packageName != null && !buildGradleContent.contains("namespace")) {
                                println("Setting namespace in ${buildGradleFile}")
                                val updatedContent = buildGradleContent.replaceFirst(
                                    "android\\s*\\{".toRegex(), "android {\n    namespace \"$packageName\""
                                )
                                buildGradleFile.writeText(updatedContent)
                            }
                        }
                    }

                    // Remove package attribute from AndroidManifest.xml
                    val manifests = project.fileTree(mapOf("dir" to project.projectDir, "includes" to listOf("**/AndroidManifest.xml")))
                    manifests.forEach { fileObj ->
                        val manifestFile = fileObj as File
                        val manifestContent = manifestFile.readText()
                        if (manifestContent.contains("package=")) {
                            println("Removing package attribute from ${manifestFile}")
                            val updatedContent = manifestContent.replace("package=\"[^\"]*\"".toRegex(), "")
                            manifestFile.writeText(updatedContent)
                        }
                    }
                }
            }

            // Ensure the task runs before the build process
            project.tasks.matching { it.name.startsWith("preBuild") }.configureEach {
                dependsOn("fixManifestsAndNamespace")
            }
        }
    }
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}