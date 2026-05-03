allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// SKRIP PENYELAMAT NAMESPACE UNTUK ISAR_FLUTTER_LIBS (KOTLIN DSL)
subprojects {
    afterEvaluate {
        project.extensions.findByName("android")?.let { androidExt ->
            try {
                val namespace = androidExt.javaClass.getMethod("getNamespace").invoke(androidExt)
                if (namespace == null) {
                    androidExt.javaClass.getMethod("setNamespace", String::class.java).invoke(androidExt, project.group.toString())
                }
            } catch (e: Exception) {
                // Abaikan jika properti tidak ditemukan
            }
        }
    }
}