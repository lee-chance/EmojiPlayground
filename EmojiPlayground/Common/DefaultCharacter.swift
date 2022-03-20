//
//  DefaultCharacter.swift
//  EmojiPlayground
//
//  Created by Changsu Lee on 2022/03/20.
//

import Foundation

enum DefaultCharacter: String, CaseIterable {
    case Apeach_Drinking        = "음료수 마시는 어피치"
    case Apeach_Fan             = "선풍기 바람 쐬는 어피치"
    case Apeach_InLove          = "하트뽀뽀 어피치"
    case Apeach_Joyful          = "신난 어피치"
    case Apeach_ListenMusic     = "음악듣는 어피치"
    case Apeach_Nervous         = "떨고있는 어피치"
    case Apeach_Proud           = "으쓱으쓱 어피치"
    case Apeach_Shy             = "부끄러운 어피치"
    case Apeach_WantSomething   = "눈빛 애교 어피치"
    case Frodo_Awkward          = "궁시렁 프로도"
    case Frodo_Cheers           = "건배하는 프로도"
    case Frodo_Hi               = "쑥스럽게 인사하는 프로도"
    case Frodo_LeavingOffice    = "퇴근하는 프로도"
    case Frodo_NewOutfit        = "멋쟁이 프로도"
    case Frodo_RockOn           = "피스메이커 프로도"
    case Frodo_Saluting         = "경례하는 프로도"
    case Frodo_Whistling        = "휘파람 프로도"
    case Frodo_YellowCard       = "옐로카드 프로도"
    case JayG_Arrogant          = "건방진 제이지"
    case JayG_Broke             = "빈털털이 제이지"
    case JayG_Chubby            = "배불뚝 제이지"
    case JayG_Dancing           = "리듬타는 제이지"
    case JayG_FacialRollers     = "얼굴마사지하는 제이지"
    case JayG_HiphopMan         = "힙합맨 제이지"
//    case JayG_HypedUp           = "엄지척 제이지"
    case JayG_Noodles           = "라면먹는 제이지"
    case JayG_Sobbing           = "울고있는 제이지"
    case JayG_Thumbs            = "엄지척 제이지"
    case Muzi_Angry             = "씩씩거리는 무지"
    case Muzi_AsleepPizza       = "피자 먹다 자는 무지"
    case Muzi_CheerUp           = "파이팅하는 무지"
    case Muzi_Cute              = "애교뿜뿜 무지"
    case Muzi_Hopeful           = "초롱초롱 무지"
    case Muzi_RiseUpHand        = "손을 번쩍 든 무지"
    case Muzi_RyanCar           = "라이언 붕붕카를 탄 무지"
    case Muzi_ShowOffMoney      = "돈다발 들고 좋아하는 무지"
    case Muzi_Tired             = "졸린 무지"
    case Muzi_WatchingTV        = "티비보는 무지"
    case Neo_CombingHair        = "머리 빗는 네오"
    case Neo_Friday             = "불금 네오"
    case Neo_Hopeful            = "초롱초롱 네오"
    case Neo_IceCream           = "아이스크림 든 네오"
    case Neo_Irritated          = "말썽쟁이 네오"
    case Neo_LovesFood          = "먹보 네오"
    case Neo_Package            = "택배 상자를 든 네오"
    case Neo_PotintingAtYou     = "뿅뿅 네오"
    case Neo_Shy                = "소심한 네오"
    case Neo_Tracksuit          = "츄리닝안경 네오"
    case Neo_Working            = "열심히 일하는 네오"
    case Neo_WorkingLate        = "불나게 일하는 네오"
    case Ryan_Block             = "블럭을 무너트리는 라이언"
    case Ryan_Cry               = "눈물바다에 빠진 라이언"
    case Ryan_Heart             = "하트뿅뿅 라이언"
    case Ryan_Mic               = "마이크를 든 라이언"
    case Ryan_Pillow            = "베개를 부비적대는 라이언"
    case Ryan_Punishment        = "벌 서는 라이언"
    case Ryan_Shy               = "부끄러워하는 라이언"
    case Ryan_Sleepy            = "졸린 라이언"
    case Ryan_Thinking          = "생각하는 라이언"
    case Tube_BlastingFire      = "불 뿜는 튜브"
    case Tube_Blowing           = "호호 부는 튜브"
    case Tube_Cleaning          = "청소하는 튜브"
    case Tube_Confused          = "멋쩍은 튜브"
    case Tube_Depressed         = "시무룩한 튜브"
    case Tube_Furious           = "화나서 방방 뛰는 튜브"
    case Tube_Hopeful           = "초롱초롱 튜브"
    case Tube_Lonely            = "벙찐 튜브"
    case Tube_RainCoat          = "비옷입은 튜브"
    case Tube_ThumbsUp          = "엄지척 튜브"
    
    var rawCharacter: KakaoCharacter {
        let characterName = self.rawValue.split(separator: " ")[1]
        return KakaoCharacter(rawValue: String(characterName)) ?? .apeach
    }
}

enum KakaoCharacter: String {
    case apeach = "어피치"
    case frodo = "프로도"
    case jayG = "제이지"
    case muzi = "무지"
    case neo = "네오"
    case ryan = "라이언"
    case tube = "튜브"
}
