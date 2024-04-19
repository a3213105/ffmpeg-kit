/*
 * Copyright (c) 2022 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include <FFmpegKitConfig.h>
#include <FFmpegSession.h>
#include <FFmpegKit.h>

int do_encoding(const char *input, const char *output)
{
    auto argumentList = ffmpegkit::FFmpegKitConfig::parseArguments("-hide_banner -f mpegts -strict -2 -bsf:v h264_mp4toannexb -c:v libx264 -preset:v veryfast -tune:v ssim -crf 23 -maxrate:v 3500k -bufsize:v 5000k -g 50 -sc_threshold 0 -pix_fmt yuv420p  -rc-lookahead 2  -c:a aac -ar 16000 -y");

    argumentList.push_front(input);
    argumentList.push_front("-i");
    argumentList.push_back(output);

    auto callback = [](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();
        auto duration = session->getDuration();

        if (ffmpegkit::ReturnCode::isSuccess(returnCode)) {
            std::cout << "Encode completed successfully, using " << duration << std::endl;
        } else {
            std::cout << "Encode failed with state " << ffmpegkit::FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;
        }
    };
    auto session = ffmpegkit::FFmpegKit::executeWithArgumentsAsync(argumentList, callback);
    while (session->getState() <= ffmpegkit::SessionState::SessionStateRunning) {
        sleep(1);
    }
    // sleep(1);
    const auto state = session->getState();
    std::cout << "#######################\n" << ffmpegkit::FFmpegKitConfig::sessionStateToString(state)
    << "\n#######################\n" << session->getCommand() << std::endl;
    return session->getReturnCode()->getValue();
}

int main(int argc, char **argv)
{
    do_encoding("/mnt/data/Meituan/video/com.sankuai.horus.aigc-85ea2e80aeb745b38d5a2661b6e277dc_8_7.ts" , "/tmp/out.ts");
    return 0;
}
