import org.jetbrains.kotlin.gradle.plugin.mpp.apple.XCFramework

plugins {
    kotlin("multiplatform") version "2.0.21"
    kotlin("plugin.serialization") version "2.0.21"
}

val ktorVersion = "2.3.12"
val coroutinesVersion = "1.8.1"
val serializationVersion = "1.7.3"

kotlin {
    val xcf = XCFramework("shared")

    // Apple Silicon Mac: iosArm64 (device) + iosSimulatorArm64 (simulator).
    // iosX64 is intentionally omitted — not needed on arm64 Mac.
    listOf(iosArm64(), iosSimulatorArm64()).forEach { target ->
        target.binaries.framework {
            baseName = "shared"
            isStatic = false   // Static = no Embed Frameworks phase needed in Xcode
            xcf.add(this)
        }
    }

    sourceSets {
        commonMain.dependencies {
            implementation("io.ktor:ktor-client-core:$ktorVersion")
            implementation("io.ktor:ktor-client-content-negotiation:$ktorVersion")
            implementation("io.ktor:ktor-serialization-kotlinx-json:$ktorVersion")
            implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:$serializationVersion")
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:$coroutinesVersion")
        }
        commonTest.dependencies {
            implementation(kotlin("test"))
            implementation("io.ktor:ktor-client-mock:$ktorVersion")
            implementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:$coroutinesVersion")
        }
        // Darwin HTTP engine for each iOS target source set.
        //
        // Why not `val iosMain by getting`?
        // In KMP 2.0 the default hierarchy template (which creates the intermediate
        // `iosMain` source set) is applied *after* the sourceSets {} block is evaluated.
        // Using `by getting` on `iosMain` at that point throws "source set not found".
        // Accessing the per-target source sets (iosArm64Main, iosSimulatorArm64Main)
        // is safe because they are created synchronously by iosArm64() / iosSimulatorArm64().
        val iosArm64Main by getting {
            dependencies {
                implementation("io.ktor:ktor-client-darwin:$ktorVersion")
            }
        }
        val iosSimulatorArm64Main by getting {
            dependencies {
                implementation("io.ktor:ktor-client-darwin:$ktorVersion")
            }
        }
    }
}

// Gradle tasks produced by XCFramework("shared"):
//   ./gradlew :shared:assembleSharedDebugXCFramework
//   ./gradlew :shared:assembleSharedReleaseXCFramework
//
// Output location:
//   shared/build/XCFrameworks/Debug/shared.xcframework
//   shared/build/XCFrameworks/Release/shared.xcframework
