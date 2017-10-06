using System;
using System.Collections;
public class stime : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_stime;
    }
    public int year;
    public int month;
    public int day;
    public int hour;
    public int minute;
    public int second;
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(year);
    	byteArray.Write(month);
    	byteArray.Write(day);
    	byteArray.Write(hour);
    	byteArray.Write(minute);
    	byteArray.Write(second);
    }

    public void decode(ByteArray byteArray)
    {
        year = byteArray.read_int();
        month = byteArray.read_int();
        day = byteArray.read_int();
        hour = byteArray.read_int();
        minute = byteArray.read_int();
        second = byteArray.read_int();
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_stime);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new stime();
    }
}

public class req_login : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_req_login;
    }
    public int version;
    public string account = "";
    public string password = "";
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(version);
    	byteArray.Write(account);
    	byteArray.Write(password);
    }

    public void decode(ByteArray byteArray)
    {
        version = byteArray.read_int();
        account = byteArray.read_string();
        password = byteArray.read_string();
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_req_login);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new req_login();
    }
}

public class notify_login_result : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_login_result;
    }
    public int result;
    public string nick_name = "";
    public int sex;
    public ArrayList body = new ArrayList();
    public ArrayList time = new ArrayList();
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(result);
    	byteArray.Write(nick_name);
    	byteArray.Write(sex);
        byteArray.Write((UInt16)body.Count);
        for(int i = 0; i < body.Count; i++)
        {
            byteArray.Write((int)body[i]);
        }
        byteArray.Write((UInt16)time.Count);
        for(int i = 0; i < time.Count; i++)
        {
            ((stime)time[i]).encode(byteArray);
        }
    }

    public void decode(ByteArray byteArray)
    {
        result = byteArray.read_int();
        nick_name = byteArray.read_string();
        sex = byteArray.read_int();
        body.Clear();
        int CountOfbody = byteArray.read_uint16();
        for(int i = 0; i < CountOfbody; i++)
        {
             body.Add(byteArray.read_int());
        }
        int CountOftime = byteArray.read_uint16();
        stime[] ArrayOftime = new stime[CountOftime];
        for(int i = 0; i < CountOftime; i++)
        {
            ArrayOftime[i] = new stime();
            ((stime)ArrayOftime[i]).decode(byteArray);
        }
        time.Clear();
        time.AddRange(ArrayOftime);
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_login_result);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_login_result();
    }
}

public class player_data : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_player_data;
    }
    public string account = "";
    public string username = "";
    public int sex;
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(account);
    	byteArray.Write(username);
    	byteArray.Write(sex);
    }

    public void decode(ByteArray byteArray)
    {
        account = byteArray.read_string();
        username = byteArray.read_string();
        sex = byteArray.read_int();
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_player_data);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new player_data();
    }
}

public class notify_heartbeat : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_heartbeat;
    }
    public void encode(ByteArray byteArray)
    {
    }

    public void decode(ByteArray byteArray)
    {
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_heartbeat);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_heartbeat();
    }
}

public class notify_sys_msg : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_sys_msg;
    }
    public int code;
    public ArrayList Params = new ArrayList();
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(code);
        byteArray.Write((UInt16)Params.Count);
        for(int i = 0; i < Params.Count; i++)
        {
            byteArray.Write((string)Params[i]);
        }
    }

    public void decode(ByteArray byteArray)
    {
        code = byteArray.read_int();
        Params.Clear();
        int CountOfParams = byteArray.read_uint16();
        for(int i = 0; i < CountOfParams; i++)
        {
             Params.Add(byteArray.read_string());
        }
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_sys_msg);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_sys_msg();
    }
}

public class notify_repeat_login : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_repeat_login;
    }
    public string account = "";
    public void encode(ByteArray byteArray)
    {
    	byteArray.Write(account);
    }

    public void decode(ByteArray byteArray)
    {
        account = byteArray.read_string();
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_repeat_login);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_repeat_login();
    }
}

public class req_create_role : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_req_create_role;
    }
    public player_data basic_data = new player_data();
    public void encode(ByteArray byteArray)
    {
        basic_data.encode(byteArray);

    }

    public void decode(ByteArray byteArray)
    {
        basic_data.decode(byteArray);
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_req_create_role);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new req_create_role();
    }
}

public class notify_create_role_result : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_create_role_result;
    }
    public void encode(ByteArray byteArray)
    {
    }

    public void decode(ByteArray byteArray)
    {
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_create_role_result);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_create_role_result();
    }
}

public class req_enter_game : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_req_enter_game;
    }
    public void encode(ByteArray byteArray)
    {
    }

    public void decode(ByteArray byteArray)
    {
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_req_enter_game);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new req_enter_game();
    }
}

public class notify_enter_game : INetPacket
{
    public short getMsgID()
    {
        return NetMsgType.msg_notify_enter_game;
    }
    public void encode(ByteArray byteArray)
    {
    }

    public void decode(ByteArray byteArray)
    {
    }
    public void build(ByteArray byteArray)
    {
        byteArray.Write(NetMsgType.msg_notify_enter_game);
        encode(byteArray);
    }
    public INetPacket Create()
    {
       return new notify_enter_game();
    }
}
