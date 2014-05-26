/*
 
 File: TransferService.h
 
 Abstract: The UUIDs generated to identify the Service and Characteristics
 used in the App.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc.
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */


#ifndef LE_Transfer_TransferService_h
#define LE_Transfer_TransferService_h


//本应用自身业务
#define TRANSFER_SERVICE_UUID           @"87025fc2-ed35-49ec-984f-4fc6a927bd13"

#define TRANSFER_CHARACTERISTIC_UUID    @"4caa4c53-d5d1-493c-8156-3831c9607026"

#define NOTIFY_CHARACTERISTIC_UUID      @"2ce2678b-5864-4fe3-aa67-8ba7a2a5c926"

//消息中心应用
#define IND_ANCS_SV_UUID @"7905F431-B5CE-4E99-A40F-4B1E122D00D0" // ANCS service
#define IND_ANCS_NS_UUID @"9FBF120D-6301-42D9-8C58-25E699A21DBD" // ANCS Notification Source
#define IND_ANCS_CP_UUID @"69D1D8F3-45E1-49A8-9821-9BBDFDAAD9D9" // ANCS Control Point
#define IND_ANCS_DS_UUID @"22EAC6E9-24D6-4BB5-BE44-B36ACE7C7BFB" // ANCS Data Source



typedef enum _TransferDataType{
    kTransferDataType_String,//0000  0x0
    kTransferDataType_File,//0010  0x2
    kTransferDataType_version //0011 0x3
}TransferDataType;

#endif