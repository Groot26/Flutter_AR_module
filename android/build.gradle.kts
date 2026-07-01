import com.android.build.gradle.LibraryExtension
import org.gradle.api.plugins.ExtensionAware
import java.io.File

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

subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = (this as ExtensionAware).extensions.findByType(LibraryExtension::class.java)
            ?: return@withId

        if (!androidExtension.namespace.isNullOrBlank()) {
            return@withId
        }

        val manifestFile = File(projectDir, "src/main/AndroidManifest.xml")
        val manifestPackage = manifestFile
            .takeIf { it.exists() }
            ?.readText()
            ?.let { Regex("""package\s*=\s*"([^"]+)"""").find(it)?.groupValues?.getOrNull(1) }

        androidExtension.namespace = manifestPackage ?: "fallback.${project.name.replace('-', '_')}"
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
